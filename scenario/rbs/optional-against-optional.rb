## update: test.rbs
class Foo
  def pos: (bool?) -> bool?
  def kw: (k: bool?) -> bool?
  def tuple: ([Integer, String]?) -> [Integer, String]?
end

## update: test.rb
class Foo
  def pos(x) = x
  def kw(k:) = k
  def tuple(x) = x
end

## diagnostics: test.rb

## assert: test.rb
class Foo
  def pos: (bool?) -> bool?
  def kw: (k: bool?) -> bool?
  def tuple: ([Integer, String]?) -> [Integer, String]?
end
