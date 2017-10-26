module Commands
  module KubeConfigUpdate
    extend ActiveSupport::Concern

    included do
      desc 'kubeconfig-update', 'Update kubectl configuration file'

      option :force,
             type: :boolean,
             desc: 'Force download the kubectl configuration file'

      def kubeconfig_update
        puts
        puts "Checking if you are using the latest version of the kubectl config file\n" \
             'You\'ll see an update message if an update was necessary'
        puts

        Services::Kube.config_download(true) if options.force?
        Services::Kube.config_download unless options.force?

        puts
        puts 'Done!'
        puts
      end
    end
  end
end
