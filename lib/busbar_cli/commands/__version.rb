module Commands
  module BusbarVersion
    extend ActiveSupport::Concern

    included do
      desc '--version', "Show Busbar's CLI version"
      map '--version' => '__version'
      map '-v' => '__version'
      def __version
        puts "The current CLI version running is: #{BUSBAR_VERSION}"
      end
    end
  end
end
