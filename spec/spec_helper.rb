$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'cocina'

class NullLogger
  def write(*args); end
end

Logify.io = NullLogger.new
