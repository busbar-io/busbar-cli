module Services
  class LatestBuildLogs
    def self.call(environment)
      loop do
        build = BuildsRepository.latest(environment)

        system('clear')
        print build.log

        break if %w(ready broken).include?(build.state)
        sleep(3)
      end
    end
  end
end
