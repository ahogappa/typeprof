## update
def kw_yielder
  yield x: 1, y: "s"
end

def empty_kw_yielder
  yield
end

def t_opt_kw_passed
  ret = nil
  kw_yielder {|x: 0, y: "default"| ret = [x, y] }
  ret
end

def t_opt_kw_default
  ret = nil
  empty_kw_yielder {|x: 0, y: "default", z: :sym| ret = [x, y, z] }
  ret
end

def t_mixed_kw
  ret = nil
  kw_yielder {|x:, y: "default", z: :sym| ret = [x, y, z] }
  ret
end

## assert
class Object
  def kw_yielder: { () -> ([Integer, String, :sym] | [Integer, String]) } -> ([Integer, String, :sym] | [Integer, String])
  def empty_kw_yielder: { () -> [Integer, String, :sym] } -> [Integer, String, :sym]
  def t_opt_kw_passed: -> [Integer, String]?
  def t_opt_kw_default: -> [Integer, String, :sym]?
  def t_mixed_kw: -> [Integer, String, :sym]?
end
