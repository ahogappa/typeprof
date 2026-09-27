## update: test.rbs
class Foo
  def req: (k: Integer) -> void
  def opt: (?k: Integer) -> void
  def rest: (**Integer) -> void
  def mixed: (a: Integer, **String) -> void
  def pack: (String, ?buffer: String) -> String
  def fmt: (String, ?pad: Integer) -> void
  def post: (String, k: Integer) -> void
  def req_rest: (String, k: Integer) -> void
  def req_noroom: (String, k: Integer) -> void
  def splat_opt: (*String, ?k: Symbol) -> void
  def keep_post: (Integer, Integer, ?j: Symbol) -> void
  def over: (k: Integer) -> void
          | (k: String) -> void
end

## update: test.rb
class Foo
  def req(h)
    @req = h
    nil
  end

  def opt(h = {})
    @opt = h
    nil
  end

  def rest(h)
    @rest = h
    nil
  end

  def mixed(h)
    @mixed = h
    nil
  end

  # the signature's String fills fmt, and no positional is left
  def pack(fmt) = fmt

  # optional keywords do not go into a rest positional
  def fmt(*args)
    @fmt = args
    nil
  end

  # required keywords go into the last positional, a post one too
  def post(s = nil, h)
    @post = h
    nil
  end

  # and into a rest positional
  def req_rest(*args)
    @req_rest = args
    nil
  end

  # with no positional left, they are left out
  def req_noroom(s) = nil

  # optional keywords do not take a positional the signature's splat may fill
  def splat_opt(a, b = nil)
    @splat_opt = b
    nil
  end

  # nor a post positional that the signature's own positionals fill
  def keep_post(a, b = 0, z)
    @keep_post = z
    nil
  end

  # keywords of one overload or the other
  def over(h)
    @over = h
    nil
  end

  def req_hash = @req
  def opt_hash = @opt
  def rest_hash = @rest
  def mixed_hash = @mixed
  def fmt_args = @fmt
  def post_hash = @post
  def req_rest_args = @req_rest
  def splat_opt_b = @splat_opt
  def keep_post_z = @keep_post
  def over_hash = @over
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def req: ({ k: Integer }) -> Object?
  def opt: (?{  } | { k: Integer }) -> Object?
  def rest: (Hash[Symbol, Integer]) -> Object?
  def mixed: (Hash[Symbol, Integer | String]) -> Object?
  def pack: (String) -> String
  def fmt: (*String) -> Object?
  def post: (?String?, { k: Integer }) -> Object?
  def req_rest: (*String | { k: Integer }) -> Object?
  def req_noroom: (String) -> Object?
  def splat_opt: (String, ?String?) -> Object?
  def keep_post: (Integer, ?Integer, Integer) -> Object?
  def over: (untyped) -> Object?
  def req_hash: -> { k: Integer }
  def opt_hash: -> ({  } | { k: Integer })
  def rest_hash: -> Hash[Symbol, Integer]
  def mixed_hash: -> Hash[Symbol, Integer | String]
  def fmt_args: -> Array[String]
  def post_hash: -> { k: Integer }
  def req_rest_args: -> Array[String | { k: Integer }]
  def splat_opt_b: -> String?
  def keep_post_z: -> Integer
  def over_hash: -> untyped
end
