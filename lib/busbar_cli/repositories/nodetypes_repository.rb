class NodeTypesRepository
  NODETYPES_ROUTE = '/nodes/'.freeze

  class << self
    def all
      nodetypes_data = JSON.parse(Request.get(NODETYPES_ROUTE).body)

      nodetypes_data.map do |nodetype_data|
        NodeType.new(nodetype_data)
      end
    end

    # def find(nodetypes_id:) # For future implementation if needed
    #   @nodetype_id = nodetype_id

    #   request = Request.get(nodetypes_route)

    #   return if request.code == '404'

    #   nodetype.new(JSON.parse(request.body)['data'])
    # end

    # private

    # def nodetypes_route
    #   "#{NODETYPES_ROUTE}#{@nodetype_id}"
    # end
  end
end
