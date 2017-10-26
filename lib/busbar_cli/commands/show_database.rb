module Commands
  module ShowDatabase
    extend ActiveSupport::Concern

    included do
      desc 'show-db NAME', 'Show details of a database'
      map 'show-database' => 'show_db'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def show_db(name)
        Services::Kube.configure_temporary_profile(options.profile)

        Printer.print_resource(DatabasesRepository.find(name: name))
      end
    end
  end
end
