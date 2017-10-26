module Services
  class EnvironmentCreator
    def self.call(app_id:, name:, buildpack_id:, public:, default_branch:, settings:)
      new(app_id, name, buildpack_id, public, default_branch, settings).call
    end

    def initialize(app_id, name, buildpack_id, public, default_branch, settings)
      @app_id = app_id
      @name = name

      @params = {
        app_id: app_id,
        name: name,
        buildpack_id: buildpack_id,
        public: public,
        default_branch: default_branch
      }

      @params = @params.merge(settings: settings) unless settings.nil?
    end

    def call
      raise_environment_creation_issue unless EnvironmentsRepository.create(@params)

      puts "Creating environment #{@name} on app #{@app_id}. This may take a while..."

      sleep(1) until environment.state == 'available'
    end

    private

    def environment
      EnvironmentsRepository.find(app_id: @app_id, environment_name: @name)
    end

    def raise_environment_creation_issue
      puts "There was an issue on the creation of #{@app_id} #{@name}.\n" \
           "Make sure that the new environment name:\n"\
           "- Is unique for its app. Ex: the same app can't have two staging environments\n" \
           '- Contains only letters, numbers, dots(.) or dashes(-)'

      exit 0
    end
  end
end
