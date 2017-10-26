module Commands
  module Version
    extend ActiveSupport::Concern

    included do
      desc 'version APP ENV', "Show an environment's version"
      method_option :profile,
                    desc: 'Profile used to run the command'
      def version(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        environment = Environment.new(app_id: app_id, name: environment_name)

        Services::LatestBuild.call(environment)
      end
    end
  end
end
