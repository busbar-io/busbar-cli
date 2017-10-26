require 'fileutils'
require 'yaml'

module Commands
  module BusbarSetup
    extend ActiveSupport::Concern

    def non_existent_key(config_key)
      puts
      puts "The config key '#{config_key}' does not exist."
      puts
      puts 'The available keys are:'
      puts Services::BusbarConfig.list_keys
      puts
      exit(1)
    end

    included do
      desc 'busbar-setup', 'Create the Busbar config file'

      option :current,
             aliases: '-c',
             banner: '',
             desc: 'Show current configuration'

      option :list_keys,
             aliases: '-k',
             banner: '',
             desc: 'List available config keys'

      option :i_set_all,
             aliases: '-a',
             banner: '',
             desc: 'Set all configuration keys interactivelly'

      option :get,
             aliases: '-g',
             desc: 'Get specific configuration key'

      option :set,
             aliases: '-s',
             banner: 'KEY=VALUE',
             desc: 'Set specific configuration key (key=value)'

      option :i_set,
             aliases: '-i',
             desc: 'Set specific configuration key interactivelly'

      option :file,
             aliases: '-f',
             desc: 'Create the busbar config using an external file'

      def busbar_setup
        if options.keys.count > 1
          puts
          puts 'You can use only a single option'
          puts

          BusbarCLI.command_help(Thor::Base.shell.new, 'busbar_setup')
          puts

          exit(1)

        elsif options.current?
          puts Services::BusbarConfig.current

        elsif options.list_keys?
          puts Services::BusbarConfig.list_keys

        elsif options.i_set_all?
          Services::BusbarConfig.interactive_set_all

        elsif options.get?
          non_existent_key(options.get) unless Services::BusbarConfig.config_key_exist(options.get)
          puts "#{options.get}: #{Services::BusbarConfig.get(options.get)}"

        elsif options.set?
          config_key = options.set.split('=')[0]
          config_value = options.set.split('=')[1]

          non_existent_key(config_key) unless Services::BusbarConfig.config_key_exist(config_key)

          unless config_value
            puts
            puts 'The configuration key must be on the format Key=Value'
            puts
            exit(1)
          end

          puts "#{config_key}: #{Services::BusbarConfig.set(config_key, config_value)}"

        elsif options.i_set?
          non_existent_key(options.i_set) unless Services::BusbarConfig.config_key_exist(options.i_set)
          puts "#{options.i_set}: #{Services::BusbarConfig.interactive_set(options.i_set)}"

        elsif options.file?
          if File.file?(BUSBAR_CONFIG_FILE_PATH)
            thor_ask = Thor::Shell::Basic.new
            puts
            puts 'Busbar config file already exists with the content bellow:'
            puts
            Services::BusbarConfig.current
            puts
            overwrite_existing = thor_ask.ask('Overwrite it',
                                              default: 'Yes',
                                              limited_to: %w(Yes No))
            exit(0) if overwrite_existing == 'No'
          end
          Services::BusbarConfig.write_from_file(options.file)

        else
          Services::BusbarConfig.current
          puts
          BusbarCLI.command_help(Thor::Base.shell.new, 'busbar_setup')
          puts
        end
        exit(0)
      end
    end
  end
end
