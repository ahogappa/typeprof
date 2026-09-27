## update: test.rbs
class Foo
  def each_x: () { (Integer) -> String } -> void
end

## update: test.rb
class Foo
  def each_x(...) = helper(...)
  def helper(&b) = b&.call(1)
end

## assert: test.rb
class Foo
  def each_x: (*untyped, **untyped) { (Integer) -> untyped } -> Object
  def helper: { (Integer) -> untyped } -> untyped
end

## update: test.rbs
class Foo
  def each_x: () -> void
end

## assert: test.rb
class Foo
  def each_x: (*untyped, **untyped) -> Object
  def helper: { (Integer) -> untyped } -> untyped
end
