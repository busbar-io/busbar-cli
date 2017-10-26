module Commands
  module Publish
    extend ActiveSupport::Concern

    included do
      desc 'publish APP ENV', 'Publish an environment'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def publish(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Publisher.call(
          Environment.new(
            app_id: app_id,
            name: environment_name
          )
        )
      end
    end
  end
end
