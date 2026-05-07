## update
def kw_yielder
  yield x: 1, y: "s"
end

def kw_yielder_pair
  yield x: 1, y: 2.0, z: :sym
end

def t_basic_kw
  ret = nil
  kw_yielder {|x:, y:| ret = [x, y] }
  ret
end

def t_kw_extra
  ret = nil
  kw_yielder_pair {|x:, y:, z:| ret = [x, y, z] }
  ret
end

## assert
class Object
  def kw_yielder: { () -> [Integer, String] } -> [Integer, String]
  def kw_yielder_pair: { () -> [Integer, Float, :sym] } -> [Integer, Float, :sym]
  def t_basic_kw: -> [Integer, String]?
  def t_kw_extra: -> [Integer, Float, :sym]?
end
