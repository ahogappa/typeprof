## update: test.rbs
class Conf
  def initialize: ({ host: String }) -> void
  def config: () -> { host: String }
  def list: () -> Array[{ name: String }]
  def missing: () -> { host: String }
end

## update: test.rb
class Conf
  def initialize(config)
    @config = config
  end

  def config = @config
  def list = [{ name: "a" }]
  def missing = { port: 1 }
end

## diagnostics: test.rb
(8,16)-(8,27): expected: { host: String }; actual: { port: Integer }
