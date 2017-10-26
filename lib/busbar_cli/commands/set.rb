module Commands
  module Set
    extend ActiveSupport::Concern

    included do
      desc 'set APP ENV SETTING=VALUE OTHER_SETTING=VALUE [...]',
           'Set one or more environment variables at once. '\
           'Use --no-deploy or --deploy=false to not deploy immediately'
      method_option :deploy,
                    default: true,
                    type: :boolean,
                    desc: 'If the environment should be deployed or not'
      method_option :profile,
                    desc: 'Profile used to run the command'
      method_option :settings,
                    type: :array,
                    desc: 'List of settings'
      def set(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name =  Services::AppConfig.get_or_exit('environment'),
        *settings
      )
        Services::Kube.configure_temporary_profile(options.profile)

        unless AppsRepository.find(app_id: app_id) &&
               EnvironmentsRepository.find(app_id: app_id, environment_name: environment_name)
          settings += [app_id, environment_name]

          puts "Could not find app or environment provided. Using values from the config file\n"

          app_id = Services::AppConfig.get_or_exit('app')
          environment_name = Services::AppConfig.get_or_exit('environment')
        end

        environment = Environment.new(app_id: app_id, name: environment_name)

        Services::Settings.set(environment, settings, options.deploy)
      end
    end
  end
end
