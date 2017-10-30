module Commands
  module AppConfig
    extend ActiveSupport::Concern

    included do
      desc 'app-config', 'Local application CLI configuration.'

      method_option :app,
                    desc: 'App to be used in further commands'
      method_option :environment,
                    desc: 'Environment to be used in further commands'
      method_option :component,
                    desc: 'Component to be used in further commands'
      method_option :reset,
                    desc: 'Reset all of your configs',
                    type: :boolean
      method_option :unset,
                    desc: 'Config to be unset'

      def app_config
        return Services::AppConfig::Displayer.call if options.empty?
        return Services::AppConfig::Reseter.call if options.reset
        return Services::AppConfig::Unseter.call(options.unset) if options.unset

        AVAILABLE_CONFIGS.each do |resource|
          next unless options.send(resource)

          Services::AppConfig.set(resource, options.send(resource))

          puts "#{resource} #{options.send(resource)} set"
        end
      end
    end
  end
end
