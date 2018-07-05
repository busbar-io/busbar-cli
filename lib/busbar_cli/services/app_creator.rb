module Services
  class AppCreator
    def self.call(id:, buildpack_id:, repository:, default_branch:, default_env:, environment:)
      new(id, buildpack_id, repository, default_branch, default_env, environment).call
    end

    def initialize(id, buildpack_id, repository, default_branch, default_env, environment)
      @id = id
      @buildpack_id = buildpack_id

      @params = {
        id: id,
        buildpack_id: buildpack_id,
        repository: repository || autodetect_repository,
        default_branch: default_branch
      }

      @params = @params.merge(default_env: default_env) unless default_env.nil?
      @params = @params.merge(environment: environment) unless environment.nil?
    end

    def call
      validate_id

      puts "Creating #{@id}, please stand by..."

      AppsRepository.create(@params)
    end

    private

    def validate_id
      return if @id.length < 54

      puts 'The application name has to be shorter than 54 characters'
      exit 1
    end

    def autodetect_repository
      `git remote get-url origin`.chomp
    end
  end
end
