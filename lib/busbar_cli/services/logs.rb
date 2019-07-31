module Services
  class Logs
    def self.call(container_id:, environment_name:, since:)
      Services::Kube.setup

      # Fetch pod data and set container name
      require 'open3'
      stdout, stderr, status = Open3.capture3(
        "#{KUBECTL} --context=#{Services::Kube.current_profile} --namespace #{environment_name} " \
        "get pod #{container_id} --output json"
      )

      # If ok => proceed
      if status.to_s.end_with?('0') then
        pod_data_json = JSON.parse(stdout)

        if pod_data_json['spec']['containers'].length == 1 then
          @container_name = pod_data_json['spec']['containers'][0]['name']
        else
          pod_data_json['spec']['containers'].each do |record|
            @container_name = record['name'] unless record['name'].end_with?('nginx')
          end
        end

        # Fetch container logs
        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} --namespace #{environment_name} " \
          "logs --follow=true --since=#{since} #{container_id} --container #{@container_name}"
        )
      else
        puts "Error while retrieving Pod data:"
        puts "  #{stderr}"
      end
    end
  end
end
