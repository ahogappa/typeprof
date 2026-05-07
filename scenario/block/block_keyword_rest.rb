## update
def kw_yielder
  yield x: 1, y: "s", z: 2.0
end

def empty_kw_yielder
  yield
end

def t_only_kwrest
  ret = nil
  kw_yielder {|**kw| ret = kw }
  ret
end

def t_kw_with_kwrest
  ret = nil
  kw_yielder {|x:, **rest| ret = [x, rest] }
  ret
end

def t_kwrest_empty
  ret = nil
  empty_kw_yielder {|**kw| ret = kw }
  ret
end

## assert
class Object
  def kw_yielder: { () -> (Hash[untyped, untyped] | [Integer, Hash[untyped, untyped] | { x: Integer, y: String, z: Float }] | { x: Integer, y: String, z: Float }) } -> (Hash[untyped, untyped] | [Integer, Hash[untyped, untyped] | { x: Integer, y: String, z: Float }] | { x: Integer, y: String, z: Float })
  def empty_kw_yielder: { () -> Hash[untyped, untyped] } -> Hash[untyped, untyped]
  def t_only_kwrest: -> (Hash[untyped, untyped] | { x: Integer, y: String, z: Float })?
  def t_kw_with_kwrest: -> [Integer, Hash[untyped, untyped] | { x: Integer, y: String, z: Float }]?
  def t_kwrest_empty: -> Hash[untyped, untyped]?
end
