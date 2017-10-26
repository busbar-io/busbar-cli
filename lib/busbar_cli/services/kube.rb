require 'busbar_cli/helpers/kube'
require 'singleton'
require 'yaml'

module Services
  class Kube
    include Singleton

    class << self
      def setup
        return if File.exist?(KUBECTL) && File.exist?(KUBECTL_CONFIG_FILE) && \
                  File.exist?(KUBECTL_CONFIG_VERSION_FILE)
        puts
        puts 'Running kubectl setup...'
        puts
        FileUtils.mkdir_p(KUBECTL_LOCAL_FOLDER) unless File.exist?(KUBECTL_LOCAL_FOLDER)
        FileUtils.mkdir_p(KUBECTL_LOCAL_BIN_FOLDER) unless File.exist?(KUBECTL_LOCAL_BIN_FOLDER)
        Helpers::Kube.install
        Helpers::Kube.config_download_file
        Helpers::Kube.config_update_local_version
      end

      def contexts
        setup
        `grep 'name:' #{KUBECTL_CONFIG_FILE} | grep -v '\\- name' |
        grep -v 'username' | sort | uniq | sed "s/name\://g; s/ //g"`.split("\n")
      end

      def configure_temporary_profile(profile = nil)
        setup
        return if profile.nil?
        validate_profile(profile)
        @current_profile = profile
      end

      def current_profile
        setup
        @current_profile || BUSBAR_PROFILE
      end

      def public_address_info_for(environment:)
        setup
        service = JSON.parse(`#{Helpers::Kube.public_info_command_for(environment)}`)
        {
          address: service['status']['loadBalancer']['ingress'][0]['hostname'],
          port: service['spec']['ports'][0]['port']
        }
      end

      def validate_profile(profile)
        setup
        puts profile
        return true if contexts.include?(profile)
        puts
        puts 'Validation Error!'
        puts "Profile must be one of the following:\n#{contexts.to_yaml}"
        puts
        exit(1)
      end

      def config_download(force = nil)
        puts 'Config file up-to-date and no force option specified...' unless \
          Helpers::Kube.config_outdated? || force
        puts 'Nothing to do.' unless Helpers::Kube.config_outdated? || force
        return unless Helpers::Kube.config_outdated? || force

        puts 'Updating kubeconfig...'
        old_version = Helpers::Kube.config_local_version
        Helpers::Kube.config_download_file
        Helpers::Kube.config_update_local_version
        puts "Kubeconfig file update from version #{old_version} to #{Helpers::Kube.config_local_version}."
      rescue SocketError
        Helpers::Kube.config_exit_with_no_connection_error
      end
    end
  end
end
