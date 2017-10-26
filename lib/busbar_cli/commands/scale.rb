module Commands
  module Scale
    extend ActiveSupport::Concern

    included do
      desc 'scale APP ENV COMPONENT_TYPE SCALE', 'Scale a component'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def scale(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment'),
        component_type = Services::AppConfig.get_or_exit('component'),
        scale
      )
        Services::Kube.configure_temporary_profile(options.profile)

        component = Component.new(
          app_id: app_id,
          environment_name: environment_name,
          type: component_type
        )

        Services::Scaler.call(component, scale)
      end
    end
  end
end
