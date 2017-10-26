module Commands
  module Wtf
    extend ActiveSupport::Concern

    included do
      desc 'wtf POD ENV [CONTAINER]',
           'Fetch the logs from a container failing to initialize (Error or CrashLoopBackOff)'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def wtf(
        pod_id,
        environment_name = Services::AppConfig.get_or_exit('environment'),
        container_id = nil
      )
        Services::Kube.configure_temporary_profile(options.profile)

        command = if container_id
                    "logs -p #{pod_id} -n #{environment_name} -c #{container_id}"
                  else
                    "logs -p #{pod_id} -n #{environment_name}"
                  end

        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} #{command}"
        )
      end
    end
  end
end
