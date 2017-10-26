module Services
  class Scaler
    def self.call(component, scale)
      Printer.print_result(
        result: ComponentsRepository.scale(component: component, scale: scale),
        success_message: "Component #{component.type} of #{component.app_id} " \
                         "#{component.environment_name} was scheduled for scaling",
        failure_message: "Error scaling component #{component.type} of " \
                         "#{component.app_id} #{component.environment_name}." \
                         'Please check its existence (and of its app/environment)'
      )
    end
  end
end
