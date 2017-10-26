module Commands
  module CreateDatabase
    extend ActiveSupport::Concern

    included do
      desc 'create-db NAME TYPE ENV', 'Create a database'
      map 'create-database' => 'create-db'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def create_db(name, type, environment)
        Services::Kube.configure_temporary_profile(options.profile)

        Services::DatabaseCreator.call(name, type, environment)
      end
    end
  end
end
