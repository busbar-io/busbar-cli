module Commands
  module Console
    extend ActiveSupport::Concern

    included do
      desc 'console APP ENV', 'Run a fresh console in the context of an application'
      method_option :profile,
                    desc: 'Profile to run the command'
      def console(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Console.call(app_id, environment_name)
      end
    end
  end
end
