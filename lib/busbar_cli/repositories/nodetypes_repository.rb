class NodetypesRepository
  NODETYPES_ROUTE = '/nodes/'.freeze

  class << self
    def all
      nodetypes_data = JSON.parse(Request.get(NODETYPES_ROUTE).body)

      nodetypes_data.map do |nodetype_data|
        Nodetype.new(nodetype_data)
      end
    end
  end
end
