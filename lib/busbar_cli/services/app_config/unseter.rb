module Services
  module AppConfig
    class Unseter
      def self.call(config)
        if AVAILABLE_CONFIGS.include?(config)
          Services::AppConfig.delete(config)
          puts "#{config} removed from local config."
        else
          puts "#{config} is not a valid config key. The valid keys are:"
          puts AVAILABLE_CONFIGS.join(' / ')
        end
      end
    end
  end
end
