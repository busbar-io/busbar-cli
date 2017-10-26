class DatabasesRepository
  DATABASES_ROUTE = '/databases/'.freeze

  class << self
    def all
      databases_data = JSON.parse(Request.get(DATABASES_ROUTE).body)['data']

      databases_data.map do |database_data|
        Database.new(database_data)
      end
    end

    def find(name:)
      @name = name

      request = Request.get(database_route)

      return if request.code == '404'

      Database.new(JSON.parse(request.body)['data'])
    end

    def create(params)
      Request.post(DATABASES_ROUTE, params).code == '201'
    end

    def destroy(database:)
      @name = database.id

      Request.delete(database_route)
    end

    private

    def database_route
      "#{DATABASES_ROUTE}#{@name}"
    end
  end
end
