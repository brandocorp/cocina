require 'forwardable'
# require 'cocina/instance/action'

module Cocina
  class Instance
    extend Forwardable

    attr_reader :name, :dependencies, :actions
    attr_accessor :runner

    def_delegators :@runner, :destroy, :create, :converge, :verify

    def initialize(name)
      @name = name
      @dependencies = []
      @actions = default_actions
    end

    # Define a dependency for the Instance
    #
    def depends(dep)
      @dependencies << dep
    end

    # Check if the Instance has any defined dependencies
    #
    def dependencies?
      dependencies.empty? ? false : true
    end

    # Set or return the list of actions
    #
    def actions(*list)
      return @actions if list.empty?
      @actions = list.flatten
    end

    # def action(name, &block)
    #   @actions << Action.new(name) do |action|
    #     action.instance_eval(&block) unless block.nil?
    #   end
    # end

    # Run all actions defined for the Instance
    #
    def run_actions
      actions.each do |action|
        # execute perform.before
        send action
      end
    end

    private

    def default_actions
      [:verify]
    end

    # Returns the current state of the Instance as recorded by the runner
    #
    def state
      @runner.last_action
    end

    # def execute(*cmds)
    #   cmds.each {|cmd| @runner.remote_exec(cmd) }
    # end
  end
end
