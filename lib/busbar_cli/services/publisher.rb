module Services
  class Publisher
    def self.call(environment)
      Printer.print_result(
        result: EnvironmentsRepository.publish(
          environment: environment
        ),
        success_message: 'Environment scheduled for publishing',
        failure_message: 'Error while publishing the environment. ' \
                         'Please check its existence (and of its app)'
      )
    end
  end
end
