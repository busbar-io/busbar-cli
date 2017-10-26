module Services
  class EnvironmentDestroyer
    def self.call(environment)
      new(environment).call
    end

    def initialize(environment)
      @environment = environment
    end

    def call
      confirm

      EnvironmentsRepository.destroy(environment: @environment)

      puts "Environment #{@environment.app_id} #{@environment.name} is scheduled for destruction"
    end

    private

    def confirm
      Confirmator.confirm(
        question: "Are you sure you want to destroy the environment #{@environment.name} " \
                   "of #{@environment.app_id} on profile #{Services::Kube.current_profile}? " \
                   'This action is irreversible.'
      )
    end
  end
end
