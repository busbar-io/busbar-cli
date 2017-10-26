require 'singleton'
require 'net/http'

module Helpers
  class Kube
    include Singleton

    class << self
      def install
        return if File.exist?(KUBECTL)
        uname = `uname`
        os = case uname
             when /Darwin/
               'darwin'
             when /Linux/
               'linux'
             end
        Net::HTTP.start('storage.googleapis.com') do |http|
          response = http.get("/kubernetes-release/release/v#{KUBECTL_VERSION}/bin/#{os}/amd64/kubectl")
          open(KUBECTL, 'wb') do |file|
            file.write(response.body)
          end
          FileUtils.chmod(0o755, KUBECTL)
        end
      end

      def public_info_command_for(environment)
        "#{KUBECTL} --context=#{Services::Kube.current_profile} get " \
        "svc/#{environment.app_id}-#{environment.name}-public "\
        "--namespace=#{environment.namespace} -o json"
      end

      def config_outdated?
        config_remote_version > config_local_version
      end

      def config_remote_version
        Net::HTTP.get(URI(KUBECTL_CONFIG_VERSION_URL)).to_i
      rescue SocketError
        config_exit_with_no_connection_error
      end

      def config_local_version
        return 0 unless File.exist?(KUBECTL_CONFIG_VERSION_FILE)
        File.read(KUBECTL_CONFIG_VERSION_FILE).to_i
      end

      def config_download_file
        response = Net::HTTP.get(URI(KUBECTL_CONFIG_FILE_URL))
        open(KUBECTL_CONFIG_FILE, 'wb') do |file|
          file.write(response)
        end
      end

      def config_update_local_version
        open(KUBECTL_CONFIG_VERSION_FILE, 'wb') do |file|
          file.write(config_remote_version)
        end
      end

      def config_exit_with_no_connection_error
        puts 'No connection could be established with the Kubectl Config ' \
             "repository (#{KUBECTL_CONFIG_FILE_URL}).\n" \
             'You may need to connect to a VPN to access it.'
        exit 0
      end
    end
  end
end
