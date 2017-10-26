module Services
  class Url
    def initialize(environment)
      @environment = environment
    end

    def self.internal(environment)
      new(environment).internal
    end

    def self.ingress(environment)
      new(environment).ingress
    end

    def self.public(environment)
      new(environment).public
    end

    def internal
      port = @environment.settings.fetch('PORT', 8080)

      "http://#{@environment.app_id}.#{@environment.name}:#{port}"
    end

    def ingress
      "http://#{@environment.app_id}.#{@environment.name}.#{Services::Kube.current_profile}"
    end

    def public
      "http://#{service_address}:#{service_port}"
    end

    private

    def service_address
      kubectl_public_info[:address]
    end

    def service_port
      kubectl_public_info[:port]
    end

    def kubectl_public_info
      @kubectl_public_info ||= Services::Kube.public_address_info_for(environment: @environment)
    end
  end
end
