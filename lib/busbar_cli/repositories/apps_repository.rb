class AppsRepository
  APPS_ROUTE = '/apps/'.freeze

  class << self
    def all
      apps_data = JSON.parse(Request.get(APPS_ROUTE).body)['data']

      apps_data.map do |app_data|
        App.new(app_data)
      end
    end

    def find(app_id:)
      @app_id = app_id

      request = Request.get(app_route)

      return if request.code == '404'

      App.new(JSON.parse(request.body)['data'])
    end

    def create(params)
      Request.post(APPS_ROUTE, params)
    end

    def destroy(app:)
      @app_id = app.id

      Request.delete(app_route)
    end

    private

    def app_route
      "#{APPS_ROUTE}#{@app_id}"
    end
  end
end
