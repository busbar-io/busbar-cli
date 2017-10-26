module Commands
  module Destroy
    extend ActiveSupport::Concern

    included do
      desc 'destroy APP [ENV]',
           'Destroy an application or an environment and all of their resources'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def destroy(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        if environment_name.nil?
          Services::AppDestroyer.call(
            App.new(id: app_id)
          )
        else
          Services::EnvironmentDestroyer.call(
            Environment.new(app_id: app_id, name: environment_name)
          )
        end
      end
    end
  end
end
