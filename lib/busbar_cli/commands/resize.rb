module Commands
  module Resize
    extend ActiveSupport::Concern

    included do
      desc 'resize APP ENV [COMPONENT_TYPE] NODE_TYPE',
           'Change the current node type of an environment or a component (Available types: 1x, 2x, 4x, 1x.standard, 2x.standard, 4x.standard, 8x.standard, 1x.performance, 2x.performance, 4x.performance, 8x.performance)'
      long_desc <<-LONGDESC
           Change the current node type of an environment or a component.

           Available types: 1x, 2x, 4x, 1x.standard, 2x.standard, 4x.standard, 8x.standard, 1x.performance, 2x.performance, 4x.performance, 8x.performance

           Types description: \x5
           1x > cpu: 1 / mem: 1500Mi \x5
           2x > cpu: 2 / mem: 3000Mi \x5
           4x > cpu: 4 / mem: 6000Mi \x5
           1x.standard > cpu: 1 / mem: 500Mi \x5
           2x.standard > cpu: 2 / mem: 1000Mi \x5
           4x.standard > cpu: 4 / mem: 2000Mi \x5
           8x.standard > cpu: 8 / mem: 4000Mi \x5
           1x.performance > cpu: 1 / mem: 1500Mi \x5
           2x.performance > cpu: 2 / mem: 3000Mi \x5
           4x.performance > cpu: 4 / mem: 6000Mi \x5
           8x.performance > cpu: 8 / mem: 12000M
           LONGDESC

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
