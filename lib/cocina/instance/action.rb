module Cocina
  class Instance
    class Action
      UnknownAction = Class.new(StandardError)
      ACTIONS = [:destroy, :create, :converge, :verify] unless defined? ACTIONS

      attr_reader :name

      def initialize(name)
        @after = []
        @before = []
        @name = name
        raise UnknownAction unless ACTIONS.include?(name)
        yield self if block_given?
      end

      def before(cmd = nil)
        return nil if create?
        return @before if cmd.nil?
        @before << cmd
      end

      def after(cmd = nil)
        return nil if destroy?
        return @after if cmd.nil?
        @after << cmd
      end

      # Check if this action is a destroy action
      # @return [Bool]
      def create?
        name == :create
      end

      # Check if this action is a destroy action
      # @return [Bool]
      def destroy?
        name == :destroy
      end
    end
  end
end
