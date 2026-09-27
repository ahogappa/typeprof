## update: test.rbs
class Foo
  def each_name: () { (String) -> Integer } -> void
  def map_name: () { (String) -> Symbol } -> Array[Symbol]
  def gen: [T] () { () -> T } -> T?
  def run: () { () -> void } -> void
  def rec: () { () -> { a: Integer } } -> { a: Integer }
  def over: () { () -> Integer } -> void
          | (Integer) { () -> String } -> void
  def pass_on: () { (String) -> Integer } -> void
  def map_ints: () { (Integer) -> String } -> void
  def maybe: () { () -> untyped? } -> void
  def opt_bool: () { () -> bool } -> bool?
end

class Box[T]
  def self.build: () { () -> instance? } -> instance?
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

  def pass_on(&blk) = receiver(&blk)

  def receiver
    @received = yield "c"
    nil
  end

  def map_ints(&blk)
    @mapped = [1].map(&blk)
    nil
  end

  def maybe
    @maybe = yield
    nil
  end

  def opt_bool = block_given? ? yield : nil

  def count = @count
  def received = @received
  def mapped = @mapped
  def maybe_value = @maybe
end

class Box
  def self.build = yield
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def each_name: { (String) -> Integer } -> Object?
  def map_name: { (String) -> Symbol } -> Array[Symbol]
  def gen: { () -> untyped } -> var[T]?
  def run: { () -> untyped } -> Object
  def rec: { () -> { a: Integer } } -> { a: Integer }
  def over: (?Integer) { () -> untyped } -> Object
  def pass_on: { (String) -> Integer } -> Object?
  def receiver: { (String) -> Integer } -> nil
  def map_ints: { (Integer) -> untyped } -> Object?
  def maybe: { () -> untyped } -> Object?
  def opt_bool: { () -> bool } -> bool?
  def count: -> Integer
  def received: -> Integer
  def mapped: -> Array[String]
  def maybe_value: -> untyped
end
class Box
  def self.build: { () -> Box[untyped]? } -> Box[untyped]?
end
