module Commands
  module Containers
    extend ActiveSupport::Concern

    included do
      desc 'containers APP ENV', 'List the containers of an application'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def containers(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} " \
          "get pods -l busbar.io/app=#{app_id} -n #{environment_name}"
        )
      end
    end
  end
end
