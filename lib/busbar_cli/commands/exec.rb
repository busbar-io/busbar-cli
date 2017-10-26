module Commands
  module Exec
    extend ActiveSupport::Concern

    included do
      desc 'exec POD ENV COMMAND',
           'Execute commands in a container.'
      method_option :profile,
                    desc: 'Profile used to execute the command'

      def exec(pod, environment, command, *command_params)
        Services::Kube.configure_temporary_profile(options.profile)

        command = "#{command} #{command_params.join(' ')}" if command_params.count.positive?

        Kernel.exec(
          "#{KUBECTL} --namespace #{environment} --context=#{Services::Kube.current_profile} " \
          "exec -ti #{pod} #{command}"
        )
      end
    end
  end
end
