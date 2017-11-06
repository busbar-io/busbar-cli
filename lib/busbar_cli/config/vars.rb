require 'busbar_cli/services'
require 'busbar_cli/config/version'

# Constants
## Hardcoded
BUSBAR_LOCAL_FOLDER         = "#{ENV['HOME']}/.busbar".freeze
BUSBAR_CONFIG_FILE_PATH     = "#{BUSBAR_LOCAL_FOLDER}/config".freeze

KUBECTL_LOCAL_FOLDER        = "#{ENV['HOME']}/.kube".freeze
KUBECTL_LOCAL_BIN_FOLDER    = "#{KUBECTL_LOCAL_FOLDER}/bin".freeze
KUBECTL_CONFIG_FILE         = "#{KUBECTL_LOCAL_FOLDER}/config".freeze
KUBECTL_CONFIG_VERSION_FILE = "#{KUBECTL_LOCAL_FOLDER}/config_version".freeze
KUBECTL                     = "#{KUBECTL_LOCAL_BIN_FOLDER}/kubectl-#{KUBECTL_VERSION}".freeze

AVAILABLE_CONFIGS           = %w(app environment component).freeze # Move to Helper::AppConfig

Services::BusbarConfig.first_run unless File.file?(BUSBAR_CONFIG_FILE_PATH)

## Overwriteable
DOCKER_PRIVATE_REGISTRY     = ENV.fetch('DOCKER_PRIVATE_REGISTRY', '127.0.0.1:5000').freeze
CONFIG_FILE_PATH            = ENV.fetch('BUSBAR_CONFIG_FILE_PATH', '.busbar.yml').freeze

## Set on config file
BUSBAR_API_URL              = ENV.fetch('BUSBAR_API_URL',
                                        Services::BusbarConfig.get('busbar_api_url')).freeze
BUSBAR_PROFILE              = ENV.fetch('BUSBAR_PROFILE',
                                        Services::BusbarConfig.get('busbar_profile')).freeze
KUBECTL_CONFIG_FILE_URL     = ENV.fetch('KUBECTL_CONFIG_FILE_URL',
                                        Services::BusbarConfig.get('kubectl_config_url')).freeze
KUBECTL_CONFIG_VERSION_URL  = ENV.fetch('KUBECTL_CONFIG_FILE_URL',
                                        Services::BusbarConfig.get('kubectl_config_version_url')).freeze
DEFAULT_BRANCH              = ENV.fetch('BRANCH',
                                        Services::BusbarConfig.get('default_git_branch')).freeze

Services::Kube.setup unless File.file?(KUBECTL_CONFIG_FILE) && \
                            File.file?(KUBECTL_CONFIG_VERSION_FILE) && File.file?(KUBECTL)
