require_relative "../helper"

module TypeProf::Core
  class RerunTest < Test::Unit::TestCase
    # Re-running boxes when nothing has changed replaces what their previous
    # runs added. Anything a run adds outside its ChangeSet stays behind, so
    # the vertices keep gaining successors with every run.
    def assert_rerun_adds_nothing(rbs, rb)
      core = Service.new({})
      core.update_rbs_file("test.rbs", rbs)
      core.update_rb_file("test.rb", rb)
      genv = core.genv
      nodes = [core.instance_variable_get(:@rb_text_nodes)["test.rb"], *core.instance_variable_get(:@rbs_text_nodes)["test.rbs"]]
      boxes = []
      nodes.each do |node|
        node.traverse {|event, n| collect_boxes(n.changes, boxes) if event == :enter }
      end
      assert_not_empty(boxes)
      vertices = []
      ObjectSpace.each_object(Vertex) {|vtx| vertices << vtx }
      rerun = -> { boxes.each {|box| box.run(genv) }; genv.run_all }
      rerun.call
      before = vertices.sum {|vtx| vtx.next_vtxs.size }
      3.times { rerun.call }
      assert_equal(before, vertices.sum {|vtx| vtx.next_vtxs.size })
    end

    def collect_boxes(changes, boxes)
      changes.boxes.each_value do |box|
        # A box without run0 (a MethodDeclBox) is not re-run.
        boxes << box unless box.class.instance_method(:run0).owner == Box
        collect_boxes(box.changes, boxes)
      end
    end

    def test_typecheck_against_a_type_variable
      assert_rerun_adds_nothing(<<~RBS, <<~RUBY)
        class Foo
          def get: [T] (T) -> T
        end
      RBS
        class Foo
          def get(x) = x
        end
      RUBY
    end

    def test_block_passed_on_from_a_declaration
      assert_rerun_adds_nothing(<<~RBS, <<~RUBY)
        class Foo
          def each_name: () { (String) -> Integer } -> void
        end
      RBS
        class Foo
          def each_name(...) = helper(...)
          def helper = yield("a")
        end
      RUBY
    end

    def test_hash_splat_in_a_hash_literal
      assert_rerun_adds_nothing(<<~RBS, <<~RUBY)
        class Foo
          def merge: (Hash[Symbol, Integer]) -> Hash[Symbol, Integer]
        end
      RBS
        class Foo
          def merge(h) = { a: 1, **h }
        end
      RUBY
    end
  end
end
