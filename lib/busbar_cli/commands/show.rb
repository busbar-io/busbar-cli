module Commands
  module Show
    extend ActiveSupport::Concern

    included do
      desc 'show APP [ENV]', 'Show details of an application or an environment'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def show(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get('environment')
      )
        Services::Kube.configure_temporary_profile(options.profile)

        resource = if environment_name.nil?
                     AppsRepository.find(app_id: app_id)
                   else
                     EnvironmentsRepository.find(environment_name: environment_name, app_id: app_id)
                   end

        Printer.print_resource(resource)
      end
    end
  end
end
