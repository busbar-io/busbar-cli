module Commands
  module Nodetypes
    extend ActiveSupport::Concern

    included do
      desc 'nodetypes', 'Show available Busbar Nodetypes'

      def nodetypes ()
        resources = NodetypesRepository.all()

        resources.map do |resource|
          Printer.print_resource(resource)
        end
      end
    end
  end
end
