## update: test.rb
class Foo
  def pm(&b) = helper(&b)
  def helper(&b) = b.call(1)
end

## assert: test.rb
class Foo
  def pm: { (Integer) -> untyped } -> untyped
  def helper: { (Integer) -> untyped } -> untyped
end

## update: test.rb
class Foo
  def pm(&b) = helper(&b)
  def helper(&b) = 1
end

## assert: test.rb
class Foo
  def pm: -> Integer
  def helper: -> Integer
end
