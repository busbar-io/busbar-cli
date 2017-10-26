class EnvironmentsRepository
  class << self
    def by_app(app_id:)
      @app_id = app_id

      request = Request.get(environments_route)

      return [] if request.code == '404'

      environments_data = JSON.parse(request.body)['data']

      environments_data.map do |environment_data|
        Environment.new(environment_data)
      end
    end

    def find(environment_name:, app_id:)
      @environment_name = environment_name
      @app_id = app_id

      request = Request.get(environment_route)

      return if request.code == '404'

      environment_data = JSON.parse(request.body)['data']

      Environment.new(environment_data)
    end

    def create(params)
      @app_id = params[:app_id]

      Request.post(environments_route, params).code == '201'
    end

    def publish(environment:)
      @app_id = environment.app_id
      @environment_name = environment.name

      Request.put("#{environment_route}/publish", {}).code == '202'
    end

    def resize(environment:, node_type:)
      @app_id = environment.app_id
      @environment_name = environment.name

      url = "#{environment_route}/resize"

      Request.put(url, node_id: node_type).code == '202'
    end

    def clone(environment:, clone_name:)
      @app_id = environment.app_id
      @environment_name = environment.name

      url = "#{environment_route}/clone"

      Request.post(url, clone_name: clone_name).code == '202'
    end

    def destroy(environment:)
      @environment_name = environment.name
      @app_id = environment.app_id

      Request.delete(environment_route).code == '204'
    end

    private

    def environment_route
      "/apps/#{@app_id}/environments/#{@environment_name}"
    end

    def environments_route
      "/apps/#{@app_id}/environments/"
    end
  end
end
