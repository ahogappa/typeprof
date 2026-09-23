## update: test.rbs
class Foo
  def each_name: () { (String) -> Integer } -> void
  def map_name: () { (String) -> Symbol } -> Array[Symbol]
  def gen: [T] () { () -> T } -> T?
  def run: () { () -> void } -> void
  def rec: () { () -> { a: Integer } } -> { a: Integer }
  def over: () { () -> Integer } -> void
          | (Integer) { () -> String } -> void
end

## update: test.rb
class Foo
  def each_name
    @count = yield "a"
    nil
  end

  def map_name(&blk)
    [blk.call("b")]
  end

  def gen = yield

  def run = yield

  def rec = yield

  def over(n = 0) = yield

  def count = @count
end

## assert: test.rb
class Foo
  def each_name: { (String) -> Integer } -> Object?
  def map_name: { (String) -> Symbol } -> Array[Symbol]
  def gen: { () -> untyped } -> var[T]?
  def run: { () -> untyped } -> Object
  def rec: { () -> { a: Integer } } -> { a: Integer }
  def over: (?Integer) { () -> untyped } -> Object
  def count: -> Integer
end
