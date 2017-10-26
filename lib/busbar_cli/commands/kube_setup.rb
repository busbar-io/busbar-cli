module Commands
  module KubeSetup
    extend ActiveSupport::Concern

    included do
      desc 'kube-setup', 'Install kubectl and its dependencies'

      def kube_setup
        puts
        puts 'Installing dependencies...'
        Services::Kube.setup
        puts 'Done!'
        puts
      end
    end
  end
end
