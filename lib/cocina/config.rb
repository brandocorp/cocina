require 'cocina/instance'

module Cocina
  class Config

    attr_reader :cocinafile, :instances

    def initialize(file)
      @cocinafile = file
      @instances = []
      @log_level = :info

      $stdout.sync = true

      load_cocinafile
      load_kitchen_config
      build_dependencies
    end

    def load_cocinafile
      self.instance_eval(IO.read(cocinafile), cocinafile, 1)
    end

    def load_kitchen_config
      @loader = Kitchen::Loader::YAML.new(
        project_config: project_kitchen_yaml,
        local_config: local_kitchen_yaml,
        global_config:  ENV["KITCHEN_GLOBAL_YAML"]
      )
      @config = Kitchen::Config.new(
        loader: @loader,
        log_level: log_level
      )
      @config.log_overwrite =
        Kitchen.env_log_overwrite unless Kitchen.env_log_overwrite.nil?
    end

    def log_level(level=nil)
      return @log_level if level.nil?
      @log_level = level
    end

    # DSL to override the base .kitchen.yml file
    def with_kitchen_yaml(file)
      @project_kitchen_yaml = file
    end

    def project_kitchen_yaml
      @project_kitchen_yaml ||= ENV["KITCHEN_YAML"]
    end

    def local_kitchen_yaml
      ENV["KITCHEN_LOCAL_YAML"]
    end

    def kitchen_instance(target)
      @config.instances.get(target)
    end

    def instance(id, &block)
      return true if instance?(id)
      cocina_instance = Cocina::Instance.new(id)
      cocina_instance.instance_eval(&block) if block
      @instances << cocina_instance
      nil
    end

    def build_dependencies
      instances.each do |machine|
        machine.runner = kitchen_instance(machine.name)
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
