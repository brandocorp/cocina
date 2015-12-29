require 'cocina/instance'

module Cocina
  class Config

    attr_reader :cocinafile, :instances

    def initialize(file)
      @cocinafile = file
      @instances = []

      $stdout.sync = true

      @loader = Kitchen::Loader::YAML.new(
        project_config: ENV["KITCHEN_YAML"],
        local_config:   ENV["KITCHEN_LOCAL_YAML"],
        global_config:  ENV["KITCHEN_GLOBAL_YAML"]
      )
      @config = Kitchen::Config.new(
        loader: @loader
      )
      @config.log_level =
        Kitchen.env_log unless Kitchen.env_log.nil?
      @config.log_overwrite =
        Kitchen.env_log_overwrite unless Kitchen.env_log_overwrite.nil?

      load_cocinafile

      build_dependencies
    end

    def load_cocinafile
      self.instance_eval(IO.read(cocinafile), cocinafile, 1)
    end

    def kitchen_instance(target)
      @config.instances.get(target)
    end

    def instance(id, &block)
      return true if instance?(id)
      cocina_instance = Cocina::Instance.new(id)
      cocina_instance.instance_eval(&block)
      cocina_instance.runner = kitchen_instance(id)
      @instances << cocina_instance
      nil
    end

    def build_dependencies
      instances.each do |machine|
        machine.dependencies.each do |id|
          next if instance?(id)
          dep = Cocina::Instance.new(id)
          dep.runner = kitchen_instance(id)
          @instances << dep
        end
      end
    end

    def instance?(id)
      instances.map(&:name).include?(id)
    end

    def [](target)
      @instances.find {|i| i.name == target }
    end
  end
end
