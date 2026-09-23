## update: test.rbs
class Foo
  def rec: ({ a: Integer }) -> { a: Integer }
  def get: [T] (T) -> T?
  def arr: (Array) -> Array
end

class Box[T]
  def me: (self) -> self?
  def put: (T) -> T?
end

## update: test.rb
class Foo
  def rec(x) = x
  def get(x) = x
  def arr(x) = x.dup
end

class Box
  def me(o) = o
  def put(x) = x
end

## assert
class Foo
  def rec: ({ a: Integer }) -> { a: Integer }
  def get: (var[T]) -> var[T]?
  def arr: (Array[untyped]) -> Array[untyped]
end
class Box
  def me: (Box[untyped]) -> Box[untyped]?
  def put: (var[T]) -> var[T]?
end
