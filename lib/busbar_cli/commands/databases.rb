module Commands
  module Databases
    extend ActiveSupport::Concern

    included do
      desc 'databases', 'List databases available'
      map 'dbs' => 'databases'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def databases
        Services::Kube.configure_temporary_profile(options.profile)

        DatabasesRepository.all.each do |database|
          puts "#{database.id} (#{database.type}) - #{database.namespace}"
        end
      end
    end
  end
end
