require 'cocina/version'
require 'cocina/cli'
require 'cocina/config'

# Cocina base module
#
# @author Brandon Raabe
module Cocina
  module_function

  # @return [String] the version
  def version
    Cocina::VERSION
  end
end
