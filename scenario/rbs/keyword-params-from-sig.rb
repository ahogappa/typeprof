## update: test.rbs
class Foo
  def foo: (name: String, ?verbose: bool, ?color: String, **Symbol) -> void
  def bar: (**Integer) -> Hash[Symbol, Integer]
  def rec: (opts: { a: Integer }) -> { a: Integer }
  def get: [T] (key: T) -> T?
  def over: (x: Integer) -> void
          | (y: String) -> void
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

  def vals = @vals
end

## assert: test.rb
class Foo
  def foo: (name: String, ?verbose: bool, ?level: Symbol?, **Symbol | String) -> Object?
  def bar: (**Integer) -> Hash[Symbol, Integer]
  def rec: (opts: { a: Integer }) -> { a: Integer }
  def get: (key: untyped) -> var[T]?
  def over: (**untyped) -> Object?
  def vals: -> Array[String | Symbol]
end
