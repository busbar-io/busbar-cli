module Services
  class Deploy
    def self.call(app_id, environment_name, branch)
      Printer.print_result(
        result: DeploymentsRepository.create(
          app_id,
          environment_name,
          branch: branch,
          build: true
        ),
        success_message: 'Deployment scheduled',
        failure_message: 'Error while deploying the environment. ' \
                         'Please check its existence (and of its app)'
      )
    end
  end
end
