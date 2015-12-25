require 'cocina/instance'

module Cocina
  class Config
    attr_reader :cocinafile
    attr_reader :instances

    def initialize(file)
      @cocinafile = file
      @instances = []
      load_cocinafile
    end

    def load_cocinafile
      self.instance_eval(IO.read(cocinafile), cocinafile, 1)
    end

    def instance(name, &block)
      i = Cocina::Instance.new(name)
      i.instance_eval(&block)
      @instances << i
    end

    def [](target)
      @instances.select {|i| i.name == target }.first
    end
  end
end
