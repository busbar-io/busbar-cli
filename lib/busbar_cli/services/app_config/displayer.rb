module Services
  module AppConfig
    class Displayer
      def self.call
        puts
        BusbarCLI.command_help(Thor::Base.shell.new, 'app_config')
        puts
        puts 'Your current application config is:'
        Services::AppConfig.all.each do |config, value|
          puts "#{config}: #{value}"
        end
      end
    end
  end
end
