module Commands
  module Deploy
    extend ActiveSupport::Concern

    included do
      desc 'deploy APP ENV [BRANCH]', 'Deploy an environment'
      method_option :log,
                    default: true,
                    type: :boolean,
                    desc: 'Display the deployment logs'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def deploy(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment'),
        branch = DEFAULT_BRANCH
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Deploy.call(app_id, environment_name, branch)

        return unless options.log

        Services::LatestBuildLogs.call(
          Environment.new(app_id: app_id, name: environment_name)
        )
      end
    end
  end
end
