module Commands
  module Apps
    extend ActiveSupport::Concern

    included do
      desc 'apps', 'List the applications'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def apps
        Services::Kube.configure_temporary_profile(options.profile)

        Services::Apps.call
      end
    end
  end
end
