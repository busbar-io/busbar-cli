module Services
  class Logs
    def self.call(app_id:, environment_name:, component_id:, since:, size:)
      Services::Kube.setup
      require 'open3'

      @environment_name = environment_name
      @app_id = app_id
      @component_id = component_id

      # Retrieve Component Data
      if @component_id.nil? then
        # retrieve app components from server
        environment_data = JSON.parse(EnvironmentsRepository.get(environment_name, app_id))
        components_data = environment_data['data']['components']

        if components_data.length == 1 then
          @component_id = components_data[0]['type']
        else
          puts "More than one component found for #{@app_id} #{@environment_name}."
          puts "Available components:"
          components_data.each do |component|
            puts "  #{component['type']}"
          end
          puts "Please choose one from the list above and try again."
          return
        end
      end

      # Retrieve a Pod Name
      stdout, stderr, status = Open3.capture3(
        "#{KUBECTL} --context=#{Services::Kube.current_profile} --namespace #{environment_name} " \
        "get pod -l busbar.io/app=#{app_id},busbar.io/component=#{@component_id} | grep -v '^NAME' | head -n 1 | awk '{print $1}'"
      )

      if status.to_s.end_with?('0') and stdout.length > 0 then
        pod_name = stdout.to_s.chomp
      else
        puts "Application not found."
        return
      end

      # Retrieve pod data and set a container name
      stdout, stderr, status = Open3.capture3(
        "#{KUBECTL} --context=#{Services::Kube.current_profile} --namespace #{environment_name} " \
        "get pod #{pod_name} --output json"
      )

      if status.to_s.end_with?('0') then
        pod_data_json = JSON.parse(stdout)

        if pod_data_json['spec']['containers'].length == 1 then
          @container_name = pod_data_json['spec']['containers'][0]['name']
        else
          pod_data_json['spec']['containers'].each do |record|
            @container_name = record['name'] unless record['name'].end_with?('nginx')
          end
        end

        # Fetch components => pod => container log
        Kernel.exec(
          "#{KUBECTL} --context=#{Services::Kube.current_profile} --namespace #{environment_name} " \
          "logs --follow=true --since=#{since} --tail=#{size} #{pod_name} --container #{@container_name}"
        )
      else
        puts "Error while retrieving pod data:"
        puts "  #{stderr}"
      end
    end
  end
end
