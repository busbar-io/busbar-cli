require 'yaml'

module Helpers
  class BusbarConfig
    CONFIG_OPTIONS = {
      busbar_api_url: {
        text: 'Please provide the Busbar API URL',
        default: nil
      },
      busbar_profile: {
        text: 'Please provide the Busbar profile',
        default: nil
      },
      kubectl_config_url: {
        text: 'Please provide the kubectl remote configuration URL',
        default: nil
      },
      kubectl_config_version_url: {
        text: 'Please provide the kubectl configuration version URL',
        default: nil
      },
      default_git_branch: {
        text: 'Please provide the default git branch',
        default: 'master'
      }
    }.freeze

    class << self
      def ensure_dependencies
        FileUtils.mkdir_p(BUSBAR_LOCAL_FOLDER) unless Dir.exist?(BUSBAR_LOCAL_FOLDER)
      end

      def create_empty_config_file
        busbar_config_hash = {}
        ensure_dependencies
        CONFIG_OPTIONS.each do |k, _|
          busbar_config_hash[k.to_s] = nil
        end
        File.open(BUSBAR_CONFIG_FILE_PATH, 'w') { |f| f.write(busbar_config_hash.to_yaml) }
      end

      def write_from_hash(busbar_config_hash, first_run)
        # Pre-Validate
        busbar_config_hash.each do |k, v|
          Services::Kube.validate_profile(v) if k == 'busbar_profile' unless first_run
        end
        # Write
        busbar_config_hash.each do |k, v|
          Services::BusbarConfig.set(k.to_s, v)
        end
      end
    end
  end
end
