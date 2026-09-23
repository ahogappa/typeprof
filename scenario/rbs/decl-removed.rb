## update: test.rbs
class Foo
  def foo: (String) -> void
end

## update: test.rb
class Foo
  def foo(x)
    @x = x
    nil
  end

  def x = @x
end

## assert: test.rb
class Foo
  def foo: (String) -> Object?
  def x: -> String
end

## update: test.rbs
class Foo
end

## assert: test.rb
class Foo
  def foo: (untyped) -> nil
  def x: -> untyped
end
