module Commands
  module Ssh
    extend ActiveSupport::Concern

    included do
      desc 'ssh CONTAINER ENV', 'Run a console in a container'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def ssh(
        container_id,
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        lines   = `tput lines`.chomp
        columns = `tput cols`.chomp

        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} exec #{container_id} -n  " \
          "#{environment_name} -i -t -- " \
          "/usr/bin/env LINES=#{lines} COLUMNS=#{columns} TERM=#{ENV['TERM']} /bin/bash -l"
        )
      end
    end
  end
end
