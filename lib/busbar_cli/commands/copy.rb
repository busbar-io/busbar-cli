module Commands
  module Copy
    extend ActiveSupport::Concern

    included do
      desc 'copy [ENV]/[POD]:/SOURCE_FILE [ENV]/[POD]:DESTINATION_FILE',
           'Copy files and directories to and from containers'
      method_option :profile,
                    desc: 'Profile used to run the command'
      method_option :container,
                    desc: 'Container name. If omitted, the first container in the pod will be chosen'

      def copy(source_file, destination_file)
        Services::Kube.configure_temporary_profile(options.profile)

        container_option = " -c #{options.container}" if options.container

        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} " \
          "cp #{source_file} #{destination_file}#{container_option}"
        )
      end
    end
  end
end
