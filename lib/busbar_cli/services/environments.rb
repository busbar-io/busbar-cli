module Services
  class Environments
    def self.call(app_id)
      environments = EnvironmentsRepository.by_app(app_id: app_id)

      puts 'ID - NAME - BUILDPACK'

      environments.each do |environment|
        puts "#{environment.id} - #{environment.name} - #{environment.buildpack_id}"
      end
    end
  end
end
