require 'logify'
require 'kitchen'
require 'kitchen/cli'

module Cocina
  class CLI
    include Logify

    attr_reader :config, :instances, :collection, :dependencies
    attr_reader :primary_instance, :primary_dependencies

    def initialize(target)
      super()

      Logify.level = :debug

      @dependencies = []
      @config = Cocina::Config.new('Cocinafile')
      @primary_instance = instance(target)
      @primary_dependencies = primary_instance.dependencies
    end

    def run
      log.info "Running for Target: #{primary_instance.name}"

      prepare_dependencies
      converge_dependencies

      primary_instance.verify
      cleanup
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
      log.info "Converging all dependencies: #{dependencies}"
      dependencies.each {|dep| converge_dependency dep }
    end

    def converge_dependency(dep)
      log.info "Converging: #{dep}"
      instance(dep).converge
    end

    def cleanup
      log.info "Cleaning up all dependencies"
      destroy_dependencies
      primary_instance.destroy
      nil
    end

    def destroy_dependencies
      dependencies.each do |dep|
        log.info "Destroying #{dep}"
        instance(dep).destroy
      end
    end
  end
end
