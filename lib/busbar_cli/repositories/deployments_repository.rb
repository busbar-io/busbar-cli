class DeploymentsRepository
  class << self
    def create(app_id, environment, params)
      Request.post(
        "/apps/#{app_id}/environments/#{environment}/deployments",
        params
      ).code == '201'
    end
  end
end
