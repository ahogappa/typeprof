## update: test.rbs
class Foo
  def fail!: () -> bot
end

## update: test.rb
class Foo
  def fail! = raise("x")
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def fail!: -> bot
end
