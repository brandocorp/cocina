module Cocina
  class Instance
    attr_reader :name, :dependencies

    def initialize(name)
      @name = name
      @dependencies = []
    end

    def depends_on(dep)
      @dependencies << dep
    end
  end
end
