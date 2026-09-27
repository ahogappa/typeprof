## update: test.rbs
class Conf
  def initialize: ({ host: String }) -> void
  def config: () -> { host: String }
  def list: () -> Array[{ name: String }]
  def missing: () -> { host: String }
  def either: (bool) -> { host: String }
end

## update: test.rb
class Conf
  def initialize(config)
    @config = config
  end

  def config = @config
  def list = [{ name: "a" }]
  def missing = { port: 1 }

  # one of the records matches, as for other unions
  def either(x) = x ? { port: 1 } : { host: "a" }
end

## diagnostics: test.rb
(8,16)-(8,27): expected: { host: String }; actual: { port: Integer }
