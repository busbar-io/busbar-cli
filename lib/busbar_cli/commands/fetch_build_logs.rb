module Commands
  module FetchBuildLogs
    extend ActiveSupport::Concern

    included do
      desc 'fetch-build-logs APP ENV', 'Get the logs from the latest build'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def fetch_build_logs(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::LatestBuildLogs.call(
          Environment.new(app_id: app_id, name: environment_name)
        )
      end
    end
  end
end
