module Commands
  module Create
    extend ActiveSupport::Concern

    included do
      desc 'create APP [ENV]', 'Create an application or an environment'
      method_option :buildpack_id,
                    type: :string,
                    desc: 'The buildpack used. Valid options are java, node and ruby.'
      method_option :public,
                    default: false,
                    type: :boolean,
                    desc: 'The application will be available to the general public'
      method_option :branch,
                    default: 'master',
                    type: :string,
                    desc: 'The branch used by default for this application. ' \
                          'All builds will use this branch unless you specify one.'
      method_option :repository,
                    type: :string,
                    desc: 'The repository of the application'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def create(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        if environment_name.nil? || AppsRepository.find(app_id: app_id).nil?
          Services::AppCreator.call(
            id: app_id,
            buildpack_id: options.buildpack_id,
            repository: options.repository,
            default_branch: options.branch,
            default_env: environment_name,
            environment: nil # Was environment_attributes - changed to comply with server side variable
          )
        else
          Services::EnvironmentCreator.call(
            app_id: app_id,
            name: environment_name,
            buildpack_id: options.buildpack_id,
            public: options.public,
            default_branch: options.branch,
            settings: nil
          )
        end

        puts 'Done!'
      end
    end
  end
end
