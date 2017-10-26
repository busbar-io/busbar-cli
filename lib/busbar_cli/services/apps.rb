module Services
  class Apps
    def self.call
      AppsRepository.all.each do |app|
        puts "#{app.id} (#{app.buildpack_id}) - #{app.environment_list}"
      end
    end
  end
end
