module Services
  class DatabaseDestroyer
    def self.call(database)
      new(database).call
    end

    def initialize(database)
      @database = database
    end

    def call
      confirm

      DatabasesRepository.destroy(database: @database)

      puts "Database #{@database.id} is scheduled for destruction"
    end

    private

    def confirm
      Confirmator.confirm(
        question: "Are you sure you want to destroy the database #{@database.id} " \
                  "on profile #{Services::Kube.current_profile}? " \
                  'This action is irreversible.'
      )
    end
  end
end
