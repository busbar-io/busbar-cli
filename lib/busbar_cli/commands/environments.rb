module Commands
  module Environments
    extend ActiveSupport::Concern

    included do
      desc 'environments APP', 'List the environments of an application'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def environments(app_id = Services::AppConfig.get_or_exit('app'))
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Environments.call(app_id)
      end
    end
  end
end
