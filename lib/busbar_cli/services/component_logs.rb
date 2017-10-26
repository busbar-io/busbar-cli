module Services
  class ComponentLogs
    def self.call(component:, size:)
      Printer.print_resource(
        ComponentsRepository.log_for(component: component, size: size)
      )
    end
  end
end
