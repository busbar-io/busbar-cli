module Services
  class Console
    def self.call(app_id, environment_name)
      new(app_id, environment_name).call
    end

    def initialize(app_id, environment_name)
      Services::Kube.setup

      @environment = EnvironmentsRepository.find(
        environment_name: environment_name,
        app_id: app_id
      )
    end

    def call
      if @environment.nil?
        puts 'Environment or app not found. Please check your input'
        exit 0
      end

      lines    = `tput lines`.chomp
      columns  = `tput cols`.chomp

      Kernel.exec(
        "#{KUBECTL} run --context=#{Services::Kube.current_profile} #{command_options} -- " \
        "/usr/bin/env LINES=#{lines} COLUMNS=#{columns} " \
        "TERM=#{ENV['TERM']} #{environment_settings} /bin/bash -li"
      )
    end

    private

    def command_options
      "#{@environment.app_id}-#{@environment.name}-console-#{Time.now.utc.to_i} " \
      "--rm --image=#{DOCKER_PRIVATE_REGISTRY}/#{@environment.id}:latest --stdin --tty " \
      "--restart=Never --image-pull-policy=Always --namespace=#{@environment.namespace}"
    end

    def environment_settings
      @environment.settings.map do |setting|
        "#{setting[0]}='#{setting[1]}'"
      end.join(' ')
    end
  end
end
