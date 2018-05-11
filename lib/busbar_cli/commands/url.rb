module Commands
  module Url
    extend ActiveSupport::Concern

    included do
      desc 'url APP ENV', 'Get the URL of an environment'
      method_option :internal,
                    default: false,
                    type: :boolean,
                    desc: 'Returns the internal URL, use this when you are accessing' \
                          'this URL from services in Busbar.'
      method_option :ingress,
                    default: false,
                    type: :boolean,
                    desc: 'Returns the ingress URL, use this when you are accessing'\
                          'this URL from services not in Busbar.'
      method_option :public,
                    default: true,
                    type: :boolean,
                    desc: 'Returns the public URL, use this when you need to access ' \
                          'a service from UI or from an external service (e.g. exchanges).'
      method_option :profile,
                    desc: 'Profile used to run the command'
      def url(
        app_id = Services::AppConfig.get_or_exit('app'),
        environment_name = Services::AppConfig.get_or_exit('environment')
      )
        if BUSBAR_PROFILE == 'minikube'
          minikube_ip = `minikube ip | tr -d '\n'`
          service_nodeport = `kubectl \
                                --namespace test get service/example-ruby \
                                -o jsonpath="{.spec.ports[0].nodePort}"`

          url = "http://#{minikube_ip}:#{service_nodeport}/"
        else
          Services::Kube.configure_temporary_profile(options.profile)

          environment = EnvironmentsRepository.find(
            app_id: app_id,
            environment_name: environment_name
          )

          url = if options.internal
                  Services::Url.internal(environment)
                elsif options.ingress || !environment.public
                  Services::Url.ingress(environment)
                elsif options.public
                  Services::Url.public(environment)
                end

        end

        puts url
      end
    end
  end
end
