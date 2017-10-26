class ComponentsRepository
  class << self
    def resize(component:, node_type:)
      @component = component

      Request.put("#{component_route}/resize", node_id: node_type).code == '202'
    end

    def scale(component:, scale:)
      @component = component

      Request.put("#{component_route}/scale", scale: scale).code == '202'
    end

    def log_for(component:, size:)
      @component = component

      request = Request.get("#{component_route}/log?size=#{size}")

      return if request.code == '404'

      logs_data = JSON.parse(request.body)['data']

      ComponentLog.new(logs_data)
    end

    private

    def component_route
      "/apps/#{@component.app_id}/environments/" \
      "#{@component.environment_name}/components/#{@component.type}"
    end
  end
end
