$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

# require 'simplecov'
# SimpleCov.start

require 'cocina'

class NullLogger
  def write(*args); end
end

# silence logging output while testing
Logify.io = NullLogger.new
