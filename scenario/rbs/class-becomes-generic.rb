## update: test.rbs
class G
  def put: (Integer) -> G
  def set: (Integer) -> G
end

## update: test.rb
class G
  def put(...) = store(...)
  def store(*) = self
  def set(x) = self
end

## update: test.rbs
class G[T]
  def put: (T) -> G[T]
  def set: (T) -> G[T]
end

## assert: test.rb
class G
  def put: (*var[T], **untyped) -> G[var[T]]
  def store: (*untyped) -> G
  def set: (var[T]) -> G[var[T]]
end
