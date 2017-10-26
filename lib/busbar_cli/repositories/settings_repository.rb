class SettingsRepository
  class << self
    def by_environment(environment:)
      @environment = environment

      request = Request.get(settings_route)

      return [] if request.code == '404'

      settings_data = JSON.parse(request.body)['data']

      settings_data.map do |setting_data|
        Setting.new(setting_data)
      end
    end

    def get(environment:, setting_key:)
      @environment = environment
      @setting = Setting.new(key: setting_key)

      request = Request.get(setting_route)

      return if request.code == '404'

      setting_data = JSON.parse(request.body)['data']
                         .merge(app_id: environment.app_id, environment_name: environment.name)

      Setting.new(setting_data)
    end

    def set(environment:, settings:, deploy:)
      @environment = environment

      Request.put("#{settings_route}/bulk", settings: settings, deploy: deploy).code == '200'
    end

    def destroy(setting:)
      @setting = setting
      @environment = Environment.new(name: setting.environment_name, app_id: setting.app_id)

      Request.delete(setting_route).code == '204'
    end

    private

    def setting_route
      "#{settings_route}/#{@setting.key.upcase}"
    end

    def settings_route
      "/apps/#{@environment.app_id}/environments/#{@environment.name}/settings"
    end
  end
end
