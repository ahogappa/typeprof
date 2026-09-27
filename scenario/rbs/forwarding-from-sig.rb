## update: test.rbs
class Foo
  def fwd: (Integer, k: String) -> void
  def fwd_block: () { (String) -> Integer } -> void
end

class Child < Parent
  def opt: (?Integer) -> void
  def rest: (**String) -> void
  def block: () { () -> Integer } -> void
  def run: (*untyped) -> untyped
end

class Base
  def visit: (Integer) -> void
end

class Visitor < Base
  def visit: (untyped node) -> untyped
end

class Base2
  def visit: (Integer, *Integer) -> void
  def visit_one: (Integer, *Integer) -> void
end

class Visitor2 < Base2
  def visit: (untyped node, *Integer) -> untyped
  def visit_one: (untyped node, Integer) -> untyped
end

class Untyped
  def fwd: (untyped x) -> untyped
end

class Logger2
  def log: (*untyped) -> void
end

class MyError < StandardError
  def initialize: (String) -> void
end

class Ov
  def fwd: () -> void
         | () { (String) -> Integer } -> void
end

class Ov2
  def fwd: () -> void
end

class Ov2
  def fwd: () { (String) -> Integer } -> void | ...
end

module Util
  def self?.helper: () { () -> String } -> untyped
  def self?.other: () { () -> String } -> untyped
end

## update: test.rb
class Foo
  def fwd(...) = helper(...)
  def fwd_block(...) = yielder(...)

  def helper(n, k:)
    @n = n
    @k = k
    nil
  end

  def yielder
    @y = yield "a"
    nil
  end

  def n = @n
  def k = @k
  def y = @y
end

class Parent
  def opt(x = nil)
    @x = x
    nil
  end

  def rest(**kw)
    @kw = kw
    nil
  end

  def block
    @b = yield
    nil
  end

  def run(a, b = 1) = a

  def x = @x
  def kw = @kw
  def b = @b
end

class Child < Parent
  def opt(x = nil) = super
  def rest(**kw) = super
  def block = super
  # passes nothing on, since *args would get untyped, which is dropped from
  # the call as if no argument were given
  def run(*args) = super
end

# passes node on as it holds it, and no block, since the signature has none
class Base
  def visit(node) = nil
end

class Visitor < Base
  def visit(node) = super
end

class Base2
  def visit(node, *r) = nil
  def visit_one(node, *r) = nil
end

# pass the rest on as well: node lands in a required positional
class Visitor2 < Base2
  def visit(node, *r) = super
  def visit_one(node, *r) = super
end

# passes nothing on, since ... would get untyped
class Untyped
  def fwd(...) = helper(...)
  def helper(x) = x
end

# neither passes a block, since their signatures have none
class Logger2
  def log(...) = puts(...)
end

class MyError < StandardError
  def initialize(msg)
    super
  end
end

# a block, since one of the method types has one
class Ov
  def fwd(...) = yielder(...)

  def yielder
    @y = yield "a"
    nil
  end
end

class Ov2
  def fwd(...) = yielder(...)

  def yielder
    @y = yield "a"
    nil
  end
end

# both boxes of a module_function def pass the block on
module Util
  module_function

  def helper(...) = other(...)
  def other = yield
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def fwd: (*Integer, **String) -> Object?
  def fwd_block: (*untyped, **untyped) { (String) -> untyped } -> Object?
  def helper: (Integer, k: String) -> nil
  def yielder: { (String) -> untyped } -> nil
  def n: -> Integer
  def k: -> String
  def y: -> untyped
end
class Parent
  def opt: (?Integer?) -> nil
  def rest: (**String) -> nil
  def block: { () -> untyped } -> nil
  def run: (untyped, ?Integer) -> untyped
  def x: -> Integer?
  def kw: -> Hash[Symbol, String]
  def b: -> untyped
end
class Child < Parent
  def opt: (?Integer?) -> Object?
  def rest: (**String) -> Object?
  def block: { () -> untyped } -> Object?
  def run: (*untyped) -> untyped
end
class Base
  def visit: (Integer) -> Object?
end
class Visitor < Base
  def visit: (untyped) -> Object
end
class Base2
  def visit: (Integer, *Integer) -> Object?
  def visit_one: (Integer, *Integer) -> Object?
end
class Visitor2 < Base2
  def visit: (untyped, *Integer) -> Object
  def visit_one: (untyped, *Integer) -> Object
end
class Untyped
  def fwd: (*untyped, **untyped) -> untyped
  def helper: (untyped) -> untyped
end
class Logger2
  def log: (*untyped, **untyped) -> Object
end
class MyError < StandardError
  def initialize: (String) -> void
end
class Ov
  def fwd: (*untyped, **untyped) { (String) -> untyped } -> Object?
  def yielder: { (String) -> untyped } -> nil
end
class Ov2
  def fwd: (*untyped, **untyped) { (String) -> untyped } -> Object?
  def yielder: { (String) -> untyped } -> nil
end
module Util
  def helper: (*untyped, **untyped) { () -> untyped } -> untyped
  def self.helper: (*untyped, **untyped) { () -> untyped } -> untyped
  def other: { () -> untyped } -> untyped
  def self.other: { () -> untyped } -> untyped
end
