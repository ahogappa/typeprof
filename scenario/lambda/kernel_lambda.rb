## update
def foo
  f = lambda { return 1 }
  f.call
  "str"
end

def bar
  lambda { break :sym }
end

def baz
  p = proc { return 1 }
  p.call
  "str"
end

## assert
class Object
  def foo: -> String
  def bar: -> Proc
  def baz: -> (Integer | String)
end
