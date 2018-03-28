module Services
  class Logs
    def self.call(container_id:, environment_name:, since:)
      Services::Kube.setup

      container_name = container_id.split('-')[0..-3].join('-')

      Kernel.exec(
        "#{KUBECTL} --context=#{Services::Kube.current_profile} " \
        "logs -f --since=#{since} #{container_id} #{container_name} -n #{environment_name}"
      )
    end
  end
end
