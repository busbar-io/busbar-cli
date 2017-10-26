require 'yaml'

module Services
  module AppConfig
    class << self
      def get_or_exit(key)
        get(key) || exit_due_key_not_present(key)
      end

      def get(key)
        config_file.fetch(key, nil)
      end

      def set(key, value)
        new_config_file = config_file
        new_config_file[key] = value
        write_config_file(new_config_file)
      end

      def delete(key)
        write_config_file(config_file.except(key))
      end

      def all
        config_file
      end

      def reset_all
        write_config_file({})
      end

      private

      def write_config_file(new_config_file)
        File.open(CONFIG_FILE_PATH, 'w') { |f| f.write new_config_file.to_yaml }
      end

      def config_file
        File.new(CONFIG_FILE_PATH, 'a')
        YAML.load_file(CONFIG_FILE_PATH) || {}
      end

      def exit_due_key_not_present(key)
        puts "#{key.upcase} not specified. "\
             'Please check command usage or specify it using the CONFIG command'
        exit 0
      end
    end
  end
end
