module Services
  class EnvironmentCloner
    def self.call(environment, clone_name)
      new(environment, clone_name).call
    end

    def initialize(environment, clone_name)
      @environment = environment
      @clone_name = clone_name
    end

    def call
      puts "Cloning #{@environment.app_id} #{@environment.name} to " \
           "#{@environment.app_id} #{@clone_name}, stand by..."

      if EnvironmentsRepository.clone(environment: @environment, clone_name: @clone_name)
        puts 'Cloning scheduled!'
      else
        puts "Some issue happened during the cloning schedule. This operations may have failed\n" \
             "Please check your inputs and Busbar's state"
      end
    end
  end
end
