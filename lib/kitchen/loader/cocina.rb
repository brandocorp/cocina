require 'kitchen/loader/yaml'
require 'kitchen/util'

module Kitchen
  module Loader
    class Cocina < YAML
      def initialize(options = {})
        super
        @cocina_config_file =
          File.expand_path(options[:cocina_config] || default_cocina_config_file)
        @process_cocina = options.fetch(:process_cocina, true)
      end

      private

      # @return [String] the absolute path to the Cocina config YAML file
      # @api private
      attr_reader :cocina_config_file

      # Performed a prioritized recursive merge of several source Hashes and
      # returns a new merged Hash. There are 4 sources of configuration data:
      #
      # 1. cocina config
      # 2. local config
      # 3. project config
      # 4. global config
      #
      # The merge order is cocina -> local -> project -> global, meaning that
      # elements at the top of the above list will be merged last, and have greater
      # precedence than elements at the bottom of the list.
      #
      # @return [Hash] a new merged Hash
      # @api private
      def combined_hash
        {}.tap do |conf|
          conf.rmerge!(normalize(global_yaml)) if @process_global
          conf.rmerge!(normalize(yaml))
          conf.rmerge!(normalize(local_yaml)) if @process_local
          conf.rmerge!(normalize(cocina_yaml)) if @process_cocina
        end
      end

      # Loads and returns the Cocina config YAML as a Hash.
      #
      # @return [Hash] the config hash
      # @api private
      def cocina_yaml
        parse_yaml_string(yaml_string(cocina_config_file), cocina_config_file)
      end

      # Determines the default absolute path to the Cocina config YAML file,
      # based on current working directory.
      #
      # @return [String] an absolute path to a Kitchen config YAML file
      # @api private
      def default_cocina_config_file
        File.join(Dir.pwd, '.cocina.kitchen.yml')
      end
    end
  end
end
