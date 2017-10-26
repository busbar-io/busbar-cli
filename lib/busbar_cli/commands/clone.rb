module Commands
  module Clone
    extend ActiveSupport::Concern

    included do
      desc 'clone APP ENV ENV_CLONE_NAME', 'Clone an environment'
      method_option :profile,
                    desc: 'Profile used to run the command'
      method_option :cluster,
                    desc: 'Destination cluster'
      def clone(app_id, environment_name, clone_name = nil)
        current_profile = options.profile || Services::Kube.current_profile
        Services::Kube.configure_temporary_profile(current_profile)

        if options.cluster.nil? && clone_name.nil?
          puts 'Param missing: [ENVIRONMENT_CLONE_NAME]'

          return
        end

        environment = Environment.new(app_id: app_id, name: environment_name)

        if options.cluster
          Services::EnvironmentClusterCloner.call(
            environment: environment,
            environment_clone_name: clone_name,
            destination_cluster: options.cluster,
            profile: current_profile
          )
        else
          Services::EnvironmentCloner.call(
            environment,
            clone_name
          )
        end
      end
    end
  end
end
