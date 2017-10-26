module Services
  class Settings
    def self.get(environment, setting_key)
      Printer.print_resource(
        SettingsRepository.get(environment: environment, setting_key: setting_key)
      )
    end

    def self.set(environment, settings_list, deploy)
      settings = settings_list.each_with_object({}) do |setting, result|
        key = setting.partition('=').first.upcase
        value = setting.partition('=').last

        result[key] = value if setting.include?('=')
      end

      Printer.print_result(
        result: SettingsRepository.set(
          environment: environment,
          settings: settings,
          deploy: deploy
        ),
        success_message: 'Settings updated with success',
        failure_message: 'Error while updating the settings. ' \
                         'Please check its existence (and of its app)'
      )
    end

    def self.by_environment(environment)
      SettingsRepository.by_environment(environment: environment).each do |setting|
        puts "#{setting.key}=#{setting.value}"
      end
    end

    def self.unset(setting)
      Printer.print_result(
        result: SettingsRepository.destroy(setting: setting),
        success_message: "Setting \"#{setting.key.upcase}\" was deleted "\
                        "from #{setting.app_id}'s #{setting.environment_name} environment",
        failure_message: 'Error while destroying setting ' \
                         "#{setting.app_id}'s #{setting.environment_name} environment. " \
                         'Please check your input'
      )
    end
  end
end
