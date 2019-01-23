module Commands
  module NodeTypes
    extend ActiveSupport::Concern

    included do
      desc 'nodetypes', 'Show available Busbar Nodetypes'

      def nodetypes ()
        resources = NodeTypesRepository.all()

        resources.map do |resource|
          Printer.print_resource(resource)
        end
      end
    end
  end
end
