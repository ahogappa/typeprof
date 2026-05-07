## update
def yielder4
  yield 1, 2, 3, 4
end

def t_post_only
  ret = nil
  yielder4 {|a, *m, z| ret = [a, m, z] }
  ret
end

def t_post_two
  ret = nil
  yielder4 {|a, *m, y, z| ret = [a, m, y, z] }
  ret
end

def t_only_post
  ret = nil
  yielder4 {|*m, z| ret = [m, z] }
  ret
end

def t_each_pair_post
  ret = nil
  [[1, "x"], [2, "y"]].each {|a, *m, z| ret = [a, m, z] }
  ret
end

def t_with_opt_post
  ret = nil
  yielder4 {|a, b = "default", *m, z| ret = [a, b, m, z] }
  ret
end

## assert
class Object
  def yielder4: { (Integer, Integer, Integer, Integer) -> ([Array[Integer], Integer] | [Integer, Array[Integer], Integer, Integer] | [Integer, Array[Integer], Integer] | [Integer, Integer | String, Array[Integer], Integer]) } -> ([Array[Integer], Integer] | [Integer, Array[Integer], Integer, Integer] | [Integer, Array[Integer], Integer] | [Integer, Integer | String, Array[Integer], Integer])
  def t_post_only: -> [Integer, Array[Integer], Integer]?
  def t_post_two: -> [Integer, Array[Integer], Integer, Integer]?
  def t_only_post: -> [Array[Integer], Integer]?
  def t_each_pair_post: -> [Integer, Array[Integer | String], String]?
  def t_with_opt_post: -> [Integer, Integer | String, Array[Integer], Integer]?
end
