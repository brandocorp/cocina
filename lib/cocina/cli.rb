require 'logify'
require 'kitchen'
require 'kitchen/cli'

module Cocina
  class CLI
    include Logify

    attr_reader :config, :instances, :dependencies, :primary_instance

    # essentially startup a Kitchen::CLI
    def initialize(target)
      super()

      $stdout.sync = true
      Logify.level = :debug

      @dependencies = []
      @config = Cocina::Config.new('Cocinafile')

      @kitchen_loader = Kitchen::Loader::YAML.new(
        project_config: ENV["KITCHEN_YAML"],
        local_config:   ENV["KITCHEN_LOCAL_YAML"],
        global_config:  ENV["KITCHEN_GLOBAL_YAML"]
      )
      @kitchen_config = Kitchen::Config.new(
        loader: @kitchen_loader
      )
      @kitchen_config.log_level =
        Kitchen.env_log unless Kitchen.env_log.nil?
      @kitchen_config.log_overwrite =
        Kitchen.env_log_overwrite unless Kitchen.env_log_overwrite.nil?

      prepare_instances_for target
    end

    def run
      log.info "Running for Target: #{primary_instance.name}"
      dependencies.each do |machine|
        log.info "Converging #{machine.name}"
        machine.converge
      end
      primary_instance.verify
      cleanup
    end

    def instance_by_name(target)
      @config[target]
    end

    def kitchen_instance_for(target)
      @kitchen_config.instances.get(target)
    end

    def prepare_instances_for(target)
      log.info "Preparing all dependencies"
      instance = instance_by_name(target)
      @primary_instance = kitchen_instance_for(target)
      instance.dependencies.each do |dependency|
        log.info "#{target} depends on #{dependency}"
        @dependencies << kitchen_instance_for(dependency)
      end
    end

    def cleanup
      log.info "Cleaning up all dependencies"
      destroy_dependencies
      primary_instance.destroy
    end

    def destroy_dependencies
      dependencies.each do |machine|
        log.info "Destroying #{machine.name}"
        machine.destroy
      end
    end
  end
end
