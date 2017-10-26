module Commands
  module Resize
    extend ActiveSupport::Concern

    included do
      desc 'resize APP ENV [COMPONENT_TYPE] NODE_TYPE',
           'Change the current node type of an environment or a component'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def resize(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment'),
        component_type = Services::AppConfig.get('component'),
        node_type
      )
        Services::Kube.configure_temporary_profile(options.profile)

        result = if component_type.nil?
                   EnvironmentsRepository.resize(
                     environment: Environment.new(
                       app_id: app_id,
                       name: environment_name
                     ),
                     node_type: node_type
                   )
                 else
                   ComponentsRepository.resize(
                     component: Component.new(
                       app_id: app_id,
                       environment_name: environment_name,
                       type: component_type
                     ),
                     node_type: node_type
                   )
                 end

        Printer.print_result(
          result: result,
          success_message: 'Resource scheduled for resizing',
          failure_message: 'Error while resizing the resource. ' \
                           'Please check its existence (and of its app)'
        )
      end
    end
  end
end
