module Services
  class Logs
    def self.call(container_id:, environment_name:, since:)
      Services::Kube.setup

      Kernel.exec(
        "#{KUBECTL} --context=#{Services::Kube.current_profile} " \
        "logs -f --since=#{since} #{container_id} -n #{environment_name}"
      )
    end
  end
end
