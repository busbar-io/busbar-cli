module Services
  class LatestBuild
    def self.call(environment)
      Printer.print_resource(
        BuildsRepository.latest(environment)
      )
    end
  end
end
