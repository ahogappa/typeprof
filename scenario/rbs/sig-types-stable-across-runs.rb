## update: test.rbs
class Foo
  def rec: ({ a: Integer }) -> { a: Integer }
  def get: [T] (T) -> T?
  def step: ({ a: Integer }) -> { a: Integer }
  def mk: () -> { a: Integer }
end

class Box[T]
  def self.coerce: (value: instance?) -> instance?
end

## update: test.rb
class Foo
  def rec(x) = x
  def get(x) = x
  def go = @y = step(@y || mk)
end

class Box
  def self.coerce(value:) = value
end

## assert: test.rb
class Foo
  def rec: ({ a: Integer }) -> { a: Integer }
  def get: (var[T]) -> var[T]?
  def go: -> { a: Integer }
end
class Box
  def self.coerce: (value: Box[untyped]?) -> Box[untyped]?
end
