module Cocina
  class Instance
    attr_reader :name, :dependencies
    attr_accessor :runner

    extend Forwardable

    def_delegators :@runner, :destroy, :create, :converge, :verify

    def initialize(name)
      @name = name
      @dependencies = []
    end

    def depends(dep)
      @dependencies << dep
    end

    def has_dependency?
      dependencies.empty? ? false : true
    end
  end
end
