module Commands
  module LatestBuild
    extend ActiveSupport::Concern

    included do
      desc 'latest_build APP ENV', "Get information from the environment's latest build"
      method_option :profile,
                    desc: 'Profile used to run the command'
      def latest_build(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::LatestBuild.call(
          Environment.new(app_id: app_id, name: environment_name)
        )
      end
    end
  end
end
