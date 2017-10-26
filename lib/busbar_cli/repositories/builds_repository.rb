class BuildsRepository
  class << self
    def latest(environment)
      @environment = environment

      request = Request.get("#{builds_route}/latest")

      return if request.code == '404'

      Build.new(JSON.parse(request.body)['data'])
    end

    private

    def builds_route
      "/apps/#{@environment.app_id}/environments/#{@environment.name}/builds"
    end
  end
end
