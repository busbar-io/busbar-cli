module Commands
  module Logs
    extend ActiveSupport::Concern

    included do
      desc 'logs APPLICATION_CONTAINER ENV [COMPONENT_TYPE]',
           'Fetch the logs from a application container. You can find the container for your application through the "busbar containers" command.'
      method_option :since,
                    default: '0',
                    type: :string,
                    desc: 'Only return logs newer than a relative duration like 5s, 2m, or 3h. ' \
                          'Defaults to all logs.'
      method_option :size,
                    default: '100',
                    type: :string,
                    desc: 'Last <size> lines of the logs to be returned' \
                          'Defaults to 100.'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def logs(
        resource_id,
        environment_name = Services::AppConfig.get_or_exit('environment'),
        component = nil
      )
        Services::Kube.configure_temporary_profile(options['profile'])

        if !component.nil? && AppsRepository.find(app_id: resource_id)
          Services::ComponentLogs.call(
            component: Component.new(
              app_id: resource_id,
              environment_name: environment_name,
              type: component
            ),
            size: options['size'].to_i
          )
        else
          Services::Logs.call(
            container_id: resource_id,
            environment_name: environment_name,
            since: options['since']
          )
        end
      end
    end
  end
end
