## update
def yielder3
  yield 1, 2, 3
end

def t_only_rest
  ret = nil
  yielder3 {|*r| ret = r }
  ret
end

def t_req_rest
  ret = nil
  yielder3 {|a, *r| ret = [a, r] }
  ret
end

def t_req_opt_rest
  ret = nil
  yielder3 {|a, b = "default", *r| ret = [a, b, r] }
  ret
end

def t_each_rest
  ret = nil
  [1, 2, 3].each {|*r| ret = r }
  ret
end

def t_each_pair_rest
  ret = nil
  [[1, "x"], [2, "y"]].each {|a, *r| ret = [a, r] }
  ret
end

## assert
class Object
  def yielder3: { (Integer, Integer, Integer) -> (Array[Integer] | [Integer, Array[Integer]] | [Integer, Integer | String, Array[Integer]]) } -> (Array[Integer] | [Integer, Array[Integer]] | [Integer, Integer | String, Array[Integer]])
  def t_only_rest: -> Array[Integer]?
  def t_req_rest: -> [Integer, Array[Integer]]?
  def t_req_opt_rest: -> [Integer, Integer | String, Array[Integer]]?
  def t_each_rest: -> Array[Integer]?
  def t_each_pair_rest: -> [Integer, Array[Integer | String]]?
end
