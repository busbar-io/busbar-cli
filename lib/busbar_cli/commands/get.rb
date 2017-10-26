module Commands
  module Get
    extend ActiveSupport::Concern

    included do
      desc 'get APP ENV SETTING',
           'Get the value of an environment variable of a given environment'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def get_config(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment'),
        setting
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Settings.get(
          Environment.new(app_id: app_id, name: environment_name), setting
        )
      end
    end
  end
end
