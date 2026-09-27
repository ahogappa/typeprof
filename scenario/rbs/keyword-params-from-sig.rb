## update: test.rbs
type any = untyped
type loose = String | untyped

class Foo
  def foo: (name: String, ?verbose: bool, ?color: String, **Symbol) -> void
  def bar: (**Integer) -> Hash[Symbol, Integer]
  def rec: (opts: { a: Integer }) -> { a: Integer }
  def get: [T] (key: T) -> T?
  def over: (x: Integer) -> void
          | (y: String) -> void
  def nested: [T] (?list: Array[T], **Integer) -> void
  def rest_var: [T] (**T) -> void
  def maybe: (to: untyped?) -> untyped
  def open: (host: String, **untyped) -> void
  def unbound: (k: untyped?) -> { k: untyped }
  def union_untyped: (to: Integer | untyped) -> void
  def top_opt: (k: top?) -> void
  def alias_opt: (k: any?) -> void
  def alias_union: (k: loose) -> void
  def generic_alias: (names: array[String]) -> void
  def named_rest: (k: Integer, **String) -> void
end

class Baz
  def m: (k: Integer) -> void
end

class Baz
  def m: (k: String) -> void | ...
end

class Bar
  def two: (k: Integer) -> void
end

class Bar
  def two: (k: String) -> void
end

## update: test.rb
class Foo
  def foo(name:, verbose: false, level: nil, **rest)
    @vals = rest.values
    nil
  end

  def bar(**rest) = rest
  def rec(opts:) = opts
  def get(key:) = key
  def over(**opts) = nil
  def nested(list: [], **rest) = nil
  def rest_var(**rest) = nil
  def maybe(to:) = to

  def open(host:, **opts)
    @logger = opts[:logger]
    nil
  end

  def unbound(**opts) = opts

  def union_untyped(to:)
    @to = to
    nil
  end

  def top_opt(k:)
    @top_opt = k
    nil
  end

  def alias_opt(k:)
    @alias_opt = k
    nil
  end

  def alias_union(k:)
    @alias_union = k
    nil
  end

  def generic_alias(names:)
    @names = names
    nil
  end

  # the def's `**` does not hold the keywords it names
  def named_rest(k:, **o)
    @named_rest = o[:k]
    nil
  end

  def vals = @vals
  def logger = @logger
  def to = @to
  def top_opt_k = @top_opt
  def alias_opt_k = @alias_opt
  def alias_union_k = @alias_union
  def names = @names
  def named_rest_k = @named_rest
end

# a `| ...` declaration makes another method type
class Baz
  def m(k:)
    @v = k
    nil
  end

  def v = @v
end

class Bar
  def two(k:) = nil
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def foo: (name: String, ?verbose: bool, ?level: Symbol?, **String | Symbol) -> Object?
  def bar: (**Integer) -> Hash[Symbol, Integer]
  def rec: (opts: { a: Integer }) -> { a: Integer }
  def get: (key: untyped) -> var[T]?
  def over: (**untyped) -> Object?
  def nested: (?list: [], **Integer) -> Object?
  def rest_var: (**untyped) -> Object?
  def maybe: (to: untyped) -> untyped
  def open: (host: String, **untyped) -> Object?
  def unbound: (**untyped) -> { k: untyped }
  def union_untyped: (to: untyped) -> Object?
  def top_opt: (k: untyped) -> Object?
  def alias_opt: (k: untyped) -> Object?
  def alias_union: (k: untyped) -> Object?
  def generic_alias: (names: untyped) -> Object?
  def named_rest: (k: Integer, **String) -> Object?
  def vals: -> Array[String | Symbol]
  def logger: -> untyped
  def to: -> untyped
  def top_opt_k: -> untyped
  def alias_opt_k: -> untyped
  def alias_union_k: -> untyped
  def names: -> untyped
  def named_rest_k: -> String
end
class Baz
  def m: (k: untyped) -> Object?
  def v: -> untyped
end
class Bar
  def two: (k: untyped) -> Object?
end
