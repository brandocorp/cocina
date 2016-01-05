require 'kitchen'
require 'kitchen/cli'

module Cocina
  class CLI

    attr_reader :config, :instances, :collection, :dependencies
    attr_reader :primary_instance, :primary_dependencies, :logger

    def initialize(target)
      super()

      @dependencies = []
      @config = Cocina::Config.new('Cocinafile')
      @logger = Kitchen::Logger.new(
        stdout: STDOUT,
        color: :white,
        progname: 'Cocina'
      )
      @primary_instance = instance(target)
      @primary_dependencies = primary_instance.dependencies
    end

    def run
      log_banner "Running for: #{primary_instance.name}"
      prepare_dependencies
      converge_dependencies
      primary_instance.run_actions
      cleanup if primary_instance.cleanup?
    end

    def instance(id)
      @config[id]
    end

    def prepare_dependencies
      primary_dependencies.each do |dep|
        @dependencies.concat instance(dep).dependencies
        @dependencies << dep
      end
    end

    def converge_dependencies
      logger.info "Dependencies: #{dependencies}"
      dependencies.each {|dep| converge_dependency dep }
    end

    def converge_dependency(dep)
      log_banner "Processing Dependency: <#{dep}>"
      instance(dep).converge
    end

    def cleanup
      log_banner "Cleaning up all dependencies"
      destroy_dependencies
      primary_instance.destroy
      nil
    end

    def destroy_dependencies
      dependencies.each do |dep|
        instance(dep).destroy
      end
    end

    def log_banner(msg)
      logger.banner "#{msg}"
    end
  end
end
