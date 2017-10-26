module Services
  class EnvironmentClusterCloner
    def self.call(environment:, environment_clone_name:, destination_cluster:, profile:)
      new(environment, environment_clone_name, destination_cluster, profile).call
    end

    def initialize(environment, environment_clone_name, destination_cluster, profile)
      @environment = environment
      @environment_clone_name = environment_clone_name
      @destination_cluster = destination_cluster
      @profile = profile
    end

    def call
      raise_environment_clone_issue if environment_exist_on_destination?

      if app_exist_on_destination?
        clone_environment
      else
        clone_app_and_environment
      end

      puts 'Remember to scale the app components'
    end

    private

    def clone_environment
      env = EnvironmentsRepository.find(
        environment_name: @environment.name,
        app_id: @environment.app_id
      )

      Services::Kube.configure_temporary_profile(@destination_cluster)

      puts "Cloning #{@environment.name} from #{@environment.app_id} #{@profile} to " \
           "#{@environment.app_id} on #{@destination_cluster}, stand by..."

      Services::EnvironmentCreator.call(
        app_id: @environment.app_id,
        name: @environment_clone_name || env.name,
        buildpack_id: env.buildpack_id,
        public: env.public,
        default_branch: env.default_branch,
        settings: env.settings
      )
    end

    def clone_app_and_environment
      app = AppsRepository.find(app_id: @environment.app_id)
      env = EnvironmentsRepository.find(environment_name: @environment.name, app_id: app.id)

      Services::Kube.configure_temporary_profile(@destination_cluster)

      environment_attributes = {
        name: @environment_clone_name || env.name,
        buildpack_id: env.buildpack_id,
        public: env.public,
        default_branch: env.default_branch,
        default_node_id: env.default_node_id,
        settings: env.settings
      }

      puts "Cloning #{@environment.app_id} #{@environment.name} from #{@profile} to " \
           "#{@environment.app_id} #{@environment_clone_name || env.name} to #{@destination_cluster}, " \
           'stand by...'

      Services::AppCreator.call(
        id: app.id,
        buildpack_id: app.buildpack_id,
        repository: app.repository,
        default_branch: app.default_branch,
        default_env: nil,
        environment: environment_attributes
      )
    end

    def environment_exist_on_destination?
      Services::Kube.configure_temporary_profile(@destination_cluster)

      env = EnvironmentsRepository.find(
        environment_name: (@environment_clone_name || @environment.name),
        app_id: @environment.app_id
      )

      Services::Kube.configure_temporary_profile(@profile)

      return true if env
    end

    def app_exist_on_destination?
      Services::Kube.configure_temporary_profile(@destination_cluster)

      app = AppsRepository.find(app_id: @environment.app_id)

      Services::Kube.configure_temporary_profile(@profile)

      return true if app
    end

    def raise_environment_clone_issue
      puts "the #{@environment_clone_name || @environment.name} already exist in the #{@destination_cluster} cluster " \
        'please, try a different name'

      exit 0
    end
  end
end
