require 'fileutils'
require 'yaml'
require 'busbar_cli/helpers/busbar_config'

module Services
  class BusbarConfig
    class << self
      @first_run = nil

      def config_key_exist(config_key)
        Helpers::BusbarConfig::CONFIG_OPTIONS.key? config_key.to_sym
      end

      def list_keys
        Helpers::BusbarConfig::CONFIG_OPTIONS.keys
      end

      def first_run
        @first_run = true
        selector_position = ARGV.count - 2

        if (ARGV[selector_position] == '-a') || (ARGV[selector_position] == '--i-set-all')
          Helpers::BusbarConfig.ensure_dependencies
          Helpers::BusbarConfig.create_empty_config_file
          interactive_set_all
          current

        elsif (ARGV[selector_position] == '-f') || (ARGV[selector_position] == '--file') || \
              (ARGV[selector_position] =~ /--file.*$/)
          file_path = if ARGV[selector_position].include?('=')
                        ARGV[selector_position].split('=')[1]
                      else
                        ARGV[selector_position + 1]
                      end
          write_from_file(file_path)
          current

        elsif (ARGV[selector_position] == '-u') || (ARGV[selector_position] == '--url') || \
              (ARGV[selector_position] =~ /--url.*$/)
          url = if ARGV[selector_position].include?('=')
                        ARGV[selector_position].split('=')[1]
                      else
                        ARGV[selector_position + 1]
                      end
          write_from_url(url)
          current

        else
          puts
          puts 'Busbar Config file not found!'
          puts
          puts 'Current Options:'
          puts '  -a, [--i-set-all]      # Set all configuration keys interactivelly'
          puts '  -f, [--file=FILE]      # Create the busbar config using an external file'
          puts '  -u, [--url=URL]        # Create the busbar config using an external URL'
          puts
        end
        exit(0)
      end

      def current
        puts
        puts 'Current Busbar configuration:'
        File.open(BUSBAR_CONFIG_FILE_PATH, 'r') { |f| puts f.read }
      end

      def get(config_key)
        return unless config_key_exist(config_key)
        busbar_config_file = File.open(BUSBAR_CONFIG_FILE_PATH, 'r')
        busbar_config_hash = YAML.safe_load(busbar_config_file)
        busbar_config_file.close
        busbar_config_hash[config_key]
      end

      def set(config_key, config_value)
        return unless config_key_exist(config_key)
        Services::Kube.validate_profile(config_value) if config_key == 'busbar_profile' unless @first_run
        Helpers::BusbarConfig.ensure_dependencies
        busbar_config_file = File.open(BUSBAR_CONFIG_FILE_PATH, 'r+')
        busbar_config_hash = YAML.safe_load(busbar_config_file)
        busbar_config_hash[config_key.to_s] = config_value
        File.open(BUSBAR_CONFIG_FILE_PATH, 'w') { |f| f.write(busbar_config_hash.to_yaml) }
        config_value
      end

      def write_from_file(file_path)
        Helpers::BusbarConfig.ensure_dependencies
        FileUtils.copy(File.expand_path(file_path), BUSBAR_CONFIG_FILE_PATH)
      end

      def write_from_url(url)
        Helpers::BusbarConfig.ensure_dependencies
        response = Net::HTTP.get(URI(url))
        open(BUSBAR_CONFIG_FILE_PATH, 'wb') do |file|
          file.write(response)
        end
      end

      def interactive_set(config_key)
        return unless Helpers::BusbarConfig::CONFIG_OPTIONS.key? config_key.to_sym

        thor_ask = Thor::Shell::Basic.new
        proceed = nil

        until proceed == 'Yes'
          exit(0) if proceed == 'No'
          puts
          config_value = thor_ask.ask(Helpers::BusbarConfig::CONFIG_OPTIONS[config_key.to_sym][:text],
                                      default: Helpers::BusbarConfig::CONFIG_OPTIONS[config_key.to_sym][:default])
          puts
          puts "The busbar config key '#{config_key}' will be set with the value '#{config_value}'"
          puts
          proceed = thor_ask.ask('Proceed', default: 'Yes', limited_to: %w(Yes No Retry))
        end

        set(config_key, config_value)
      end

      def interactive_set_all
        thor_ask = Thor::Shell::Basic.new
        busbar_config_hash = {}
        proceed = nil

        until proceed == 'Yes'
          exit(0) if proceed == 'No'
          puts

          Helpers::BusbarConfig::CONFIG_OPTIONS.each do |config_key, _|
            config_value = thor_ask.ask(Helpers::BusbarConfig::CONFIG_OPTIONS[config_key][:text],
                                        default: Helpers::BusbarConfig::CONFIG_OPTIONS[config_key][:default])
            busbar_config_hash[config_key.to_s] = config_value
          end

          puts
          puts 'The Busbar config file will be created with the options bellow:'
          puts
          puts busbar_config_hash.to_yaml
          puts
          proceed = thor_ask.ask('Proceed', default: 'Yes', limited_to: %w(Yes No Retry))
        end

        Helpers::BusbarConfig.write_from_hash(busbar_config_hash, @first_run)
      end
    end
  end
end
