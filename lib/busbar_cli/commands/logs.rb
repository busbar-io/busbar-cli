module Commands
  module Logs
    extend ActiveSupport::Concern

    included do
      desc 'logs APP ENV [COMPONENT]',
        'Stream the application logs.'
      method_option :since,
                    default: '0',
                    type: :string,
                    desc: 'Look-back duration in seconds, minutes, or hours (5s, 2m, 3h).'
      method_option :size,
                    default: '30',
                    type: :string,
                    desc: 'Number of lines.'
      method_option :profile,
                    desc: 'Profile used to run the command.'
      def logs(
        app_id,
        environment_name,
        component_id = nil
      )
        Services::Kube.configure_temporary_profile(options['profile'])

        Services::Logs.call(
          app_id: app_id,
          environment_name: environment_name,
          component_id: component_id,
          since: options['since'],
          size: options['size'].to_i
        )
      end
    end
  end
end
