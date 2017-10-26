module Commands
  module DestroyDatabase
    extend ActiveSupport::Concern

    included do
      desc 'destroy-db DB-NAME', 'Destroy a database'
      map 'destroy-database' => 'destroy-db'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def destroy_db(database_id)
        Services::Kube.configure_temporary_profile(options.profile)

        database = DatabasesRepository.find(name: database_id)

        if database.nil?
          puts "Database #{database_id} not found"
          return
        end

        Services::DatabaseDestroyer.call(database)
      end
    end
  end
end
