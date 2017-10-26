module Commands
  module Settings
    extend ActiveSupport::Concern

    included do
      desc 'settings APP ENV', 'List the settings of an environment'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def settings(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        environment = Environment.new(app_id: app_id, name: environment_name)

        Services::Settings.by_environment(environment)
      end
    end
  end
end
