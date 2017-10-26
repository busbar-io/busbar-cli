module Commands
  module Unset
    extend ActiveSupport::Concern

    included do
      desc 'unset APP ENV SETTING', 'Delete an environment variable'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def unset(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment'),
        setting_key
      )
        Services::Kube.configure_temporary_profile(options.profile)

        setting = Setting.new(app_id: app_id, environment_name: environment_name, key: setting_key)

        Services::Settings.unset(setting)
      end
    end
  end
end
