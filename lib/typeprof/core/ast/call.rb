module TypeProf::Core
  class AST
    # A literal block: the `do ... end` / `{ ... }` given to a call, or a `-> {}`.
    # @lenv is the enclosing scope the block closes over; the body gets its own.
    class BlockNode < Node
      def initialize(raw_node, lenv, mid)
        super(raw_node, lenv)

        @tbl = raw_node.locals
        @multi_targets = {}
        @f_args = case raw_node.parameters
                  when Prism::BlockParametersNode
                    # `{ || ... }` (empty pipes) and `{ |; x| ... }`
                    # (block-local-only) yield BlockParametersNode
                    # whose inner `parameters` is nil.
                    params = raw_node.parameters.parameters
                    if params
                      req = params.requireds.each_with_index.map do |n, i|
                        if n.is_a?(Prism::MultiTargetNode)
                          @multi_targets[i] = n
                          nil
                        else
                          n.name
                        end
                      end
                      opt = params.optionals.map {|n| n.name }
                      req + opt
                    else
                      []
                    end
                  when Prism::NumberedParametersNode
                    1.upto(raw_node.parameters.maximum).map { |n| :"_#{n}" }
                  when Prism::ItParametersNode
                    [:it]
                  when nil
                    []
                  else
                    raise "not supported yet: #{ raw_node.parameters.class }"
                  end
        ncref = CRef.new(lenv.cref.cpath, :instance, mid, lenv.cref)
        nlenv = LocalEnv.new(lenv.file_context, ncref, {}, lenv.return_boxes)
        @opt_positional_defaults = []
        if raw_node.parameters.is_a?(Prism::BlockParametersNode) && raw_node.parameters.parameters
          raw_node.parameters.parameters.optionals.each do |n|
            @opt_positional_defaults << AST.create_node(n.value, nlenv)
          end
        end
        @body = raw_node.body ? AST.create_node(raw_node.body, nlenv) : DummyNilNode.new(code_range, lenv)
      end

      attr_reader :tbl, :f_args, :opt_positional_defaults, :body, :multi_targets

      def subnodes = { opt_positional_defaults:, body: }
      def attrs = { tbl:, f_args: }

      def install0(genv)
        body = @body # kinda type annotationty
        body.lenv.forward_args = @lenv.forward_args
        @lenv.locals.each {|var, vtx| body.lenv.locals[var] = vtx }
        @tbl.each {|var| body.lenv.locals[var] = Source.new(genv.nil_type) }
        body.lenv.locals[:"*self"] = body.lenv.cref.get_self(genv)

        f_args = @f_args.map {|arg| body.lenv.new_var(arg, self) }

        unless @opt_positional_defaults.empty?
          req_count = f_args.size - @opt_positional_defaults.size
          @opt_positional_defaults.each_with_index do |expr, i|
            @changes.add_edge(genv, expr.install(genv), f_args[req_count + i])
          end
        end

        @multi_targets.each do |idx, raw_multi_target|
          param_vtx = f_args[idx]
          lefts = raw_multi_target.lefts.map do |n|
            body.lenv.new_var(n.is_a?(Prism::MultiTargetNode) ? nil : n.name, self)
          end
          @changes.add_masgn_box(genv, param_vtx, lefts, nil, nil)
        end

        @lenv.locals.each do |var, vtx|
          body.lenv.set_var(var, vtx)
        end
        vars = []
        body.modified_vars(@lenv.locals.keys - @tbl, vars)
        vars.uniq!
        vars.each do |var|
          vtx = @lenv.get_var(var)
          nvtx = vtx.new_vertex(genv, self)
          @lenv.set_var(var, nvtx)
          body.lenv.set_var(var, nvtx)
        end

        body.lenv.locals[:"*expected_block_ret"] = Vertex.new(self)
        body.install(genv)
        body.lenv.add_next_box(@changes.add_escape_box(genv, body.ret))

        vars.each do |var|
          @changes.add_edge(genv, body.lenv.get_var(var), @lenv.get_var(var))
        end

        f_ary_arg = Vertex.new(self)
        # TODO: support splat "do |a, *b, c|"
        f_args.each_with_index do |f_arg, i|
          elem_vtx = @changes.add_splat_box(genv, f_ary_arg, i).ret
          @changes.add_edge(genv, elem_vtx, f_arg)
        end
        block = Block.new(self, f_ary_arg, f_args, body.lenv.next_boxes)
        Source.new(Type::Proc.new(genv, block))
      end

      # Block-local variables shadow the outer ones, so writes to them are not
      # modifications of the enclosing scope.
      def modified_vars(tbl, vars)
        @opt_positional_defaults.each {|n| n.modified_vars(tbl, vars) }
        @body.modified_vars(tbl - @tbl, vars)
      end

      def break_vtx = @body.lenv.break_vtx

      def last_stmt_code_range
        if @body.is_a?(AST::StatementsNode)
          @body.stmts.last.code_range
        else
          @body.code_range
        end
      end
    end

    class CallBaseNode < Node
      def initialize(raw_node, recv, mid, mid_code_range_loc, raw_args, last_arg, raw_block, lenv, forwarding_arguments: false)
        super(raw_node, lenv)

        @recv = recv
        @mid = mid
        @mid_code_range_loc = mid_code_range_loc

        # args
        @positional_args = []
        @splat_flags = []
        @keyword_args = nil

        @block_pass = nil
        @block = nil
        @safe_navigation = raw_node.respond_to?(:safe_navigation?) && raw_node.safe_navigation?
        @anonymous_block_forwarding = false
        @forwarding_arguments = forwarding_arguments

        if raw_args
          args = []
          @splat_flags = []
          raw_args.arguments.each do |raw_arg|
            case raw_arg
            when Prism::SplatNode
              args << raw_arg.expression
              @splat_flags << true
            when Prism::ForwardingArgumentsNode
              @forwarding_arguments = :rest
            else
              args << raw_arg
              @splat_flags << false
            end
          end
          @positional_args = args.map {|arg| arg ? AST.create_node(arg, lenv) : nil }

          kw = @positional_args.last
          if kw.is_a?(TypeProf::Core::AST::HashNode) && kw.keywords
            @keyword_args = @positional_args.pop
          end
        end

        @positional_args << last_arg if last_arg

        if raw_block
          if raw_block.type == :block_argument_node
            if raw_block.expression
              @block_pass = AST.create_node(raw_block.expression, lenv)
            else
              @anonymous_block_forwarding = true
            end
          else
            @block = BlockNode.new(raw_block, lenv, @mid)
          end
        end

        @yield = raw_node.type == :yield_node
      end

      attr_reader :recv, :mid, :yield

      def mid_code_range
        @mid_code_range ||= @lenv.code_range_from_node(@mid_code_range_loc) if @mid_code_range_loc
      end
      attr_reader :positional_args, :splat_flags, :keyword_args
      attr_reader :block, :block_pass, :anonymous_block_forwarding
      attr_reader :safe_navigation, :forwarding_arguments

      def subnodes = { recv:, positional_args:, keyword_args:, block:, block_pass: }
      def attrs = { mid:, splat_flags:, yield:, safe_navigation:, anonymous_block_forwarding:, forwarding_arguments: }

      def install0(genv)
        recv = @recv ? @recv.install(genv) : @yield ? @lenv.get_var(:"*given_block") : @lenv.get_var(:"*self")

        if @safe_navigation
          allow_nil = NilFilter.new(genv, self, recv, true).next_vtx
          recv = NilFilter.new(genv, self, recv, false).next_vtx
        end

        if @forwarding_arguments
          forward_a_args = (@lenv.forward_args || raise).to_actual_arguments(
            genv,
            @changes,
            self,
            include_leading_positionals: @forwarding_arguments != :rest,
            activation_required: @forwarding_arguments == :rest,
          )
          # An anonymous rest cannot appear here: `bar(*, ...)` is a syntax error
          leading_args = @positional_args.map {|arg| arg.install(genv) }
          a_args = forward_a_args.prepend_positionals(leading_args, @splat_flags)
          a_args = a_args.with_keywords(@keyword_args.install(genv)) if @keyword_args
        else
          positional_args = @positional_args.map do |arg|
            if arg.nil?
              @lenv.get_var(:"*anonymous_rest")
            else
              arg.install(genv)
            end
          end
          a_args = ActualArguments.new(positional_args, @splat_flags, @keyword_args ? @keyword_args.install(genv) : nil, nil)
        end

        if @block
          blk_ty = @block.install(genv)
        elsif @block_pass
          blk_ty = @block_pass.install(genv)
        elsif @anonymous_block_forwarding
          blk_ty = @lenv.get_var(:"*anonymous_block")
        elsif @forwarding_arguments
          blk_ty = forward_a_args.block
        end

        if @forwarding_arguments
          a_args = a_args.with_block(blk_ty, omittable: !@block && !@block_pass && !@anonymous_block_forwarding)
        else
          a_args = a_args.with_block(blk_ty)
        end
        box = @changes.add_method_call_box(genv, recv, @mid, a_args, !@recv)

        if @block && @block.break_vtx
          ret = Vertex.new(self)
          @changes.add_edge(genv, box.ret, ret)
          @changes.add_edge(genv, @block.break_vtx, ret)
        else
          ret = box.ret
        end

        if @safe_navigation
          @changes.add_edge(genv, allow_nil, ret)
        end

        ret
      end

      def retrieve_at(pos, &blk)
        yield self if mid_code_range&.include?(pos)
        each_subnode do |subnode|
          next unless subnode
          subnode.retrieve_at(pos, &blk)
        end
      end

    end

    class CallNode < CallBaseNode
      def initialize(raw_node, lenv)
        recv = raw_node.receiver ? AST.create_node(raw_node.receiver, lenv) : nil
        mid = raw_node.name
        raw_args = raw_node.arguments
        raw_block = raw_node.block
        super(raw_node, recv, mid, raw_node.message_loc, raw_args, nil, raw_block, lenv)
      end

      def narrowings
        @narrowings ||= begin
          args = @positional_args
          case @mid
          when :is_a?
            if @recv.is_a?(LocalVariableReadNode) && args && args.size == 1
              [
                Narrowing.new({ @recv.var => Narrowing::IsAConstraint.new(args[0], false) }),
                Narrowing.new({ @recv.var => Narrowing::IsAConstraint.new(args[0], true) })
              ]
            elsif @recv.is_a?(InstanceVariableReadNode) && args && args.size == 1
              [
                Narrowing.new({ @recv.var => Narrowing::IsAConstraint.new(args[0], false) }),
                Narrowing.new({ @recv.var => Narrowing::IsAConstraint.new(args[0], true) })
              ]
            else
              super
            end
          when :nil?
            if @recv.is_a?(LocalVariableReadNode)
              [
                Narrowing.new({ @recv.var => Narrowing::NilConstraint.new(true) }),
                Narrowing.new({ @recv.var => Narrowing::NilConstraint.new(false) })
              ]
            elsif @recv.is_a?(InstanceVariableReadNode)
              [
                Narrowing.new({ @recv.var => Narrowing::NilConstraint.new(true) }),
                Narrowing.new({ @recv.var => Narrowing::NilConstraint.new(false) })
              ]
            else
              super
            end
          when :!
            then_narrowing, else_narrowing = @recv.narrowings
            [else_narrowing, then_narrowing]
          else
            super
          end
        end
      end
    end

    class SuperNode < CallBaseNode
      def initialize(raw_node,  lenv)
        raw_args = raw_node.arguments
        raw_block = raw_node.block
        super(raw_node, nil, :"*super", nil, raw_args, nil, raw_block, lenv)
      end
    end

    class ForwardingSuperNode < CallBaseNode
      def initialize(raw_node,  lenv)
        raw_args = nil
        raw_block = raw_node.block
        super(raw_node, nil, :"*super", nil, raw_args, nil, raw_block, lenv, forwarding_arguments: :all)
      end
    end

    class YieldNode < CallBaseNode
      def initialize(raw_node, lenv)
        raw_args = raw_node.arguments
        super(raw_node, nil, :call, nil, raw_args, nil, nil, lenv)
      end
    end

    class OperatorNode < CallBaseNode
      def initialize(raw_node, recv, lenv)
        mid = raw_node.binary_operator
        last_arg = AST.create_node(raw_node.value, lenv)
        super(raw_node, recv, mid, raw_node.binary_operator_loc, nil, last_arg, nil, lenv)
      end
    end

    class IndexReadNode < CallBaseNode
      def initialize(raw_node, lenv)
        recv = AST.create_node(raw_node.receiver, lenv)
        mid = :[]
        mid_code_range = nil
        raw_args = raw_node.arguments
        super(raw_node, recv, mid, mid_code_range, raw_args, nil, nil, lenv)
      end
    end

    class IndexWriteNode < CallBaseNode
      def initialize(raw_node, rhs, lenv)
        recv = AST.create_node(raw_node.receiver, lenv)
        mid = :[]=
        mid_code_range = nil
        raw_args = raw_node.arguments
        @rhs = rhs
        super(raw_node, recv, mid, mid_code_range, raw_args, rhs, nil, lenv)
      end

      attr_reader :rhs
    end

    class CallReadNode < CallBaseNode
      def initialize(raw_node, lenv)
        recv = AST.create_node(raw_node.receiver, lenv)
        mid = raw_node.read_name
        super(raw_node, recv, mid, raw_node.message_loc, nil, nil, nil, lenv)
      end
    end

    class CallWriteNode < CallBaseNode
      def initialize(raw_node, rhs, lenv)
        recv = AST.create_node(raw_node.receiver, lenv)
        mid = raw_node.is_a?(Prism::CallTargetNode) ? raw_node.name : raw_node.write_name
        @rhs = rhs
        super(raw_node, recv, mid, raw_node.message_loc, nil, rhs, nil, lenv)
      end

      attr_reader :rhs
    end
  end
end
