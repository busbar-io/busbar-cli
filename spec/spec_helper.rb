require 'rspec'
require 'yaml'
require 'webmock/rspec'
require 'fakefs/spec_helpers'

TEST_APP_CONFIG_FILE_PATH = '.test-app-config-file.yml'.freeze

# Mocking the config file
ENV['HOME'] = '/tmp'
TEST_BUSBAR_LOCAL_FOLDER = "#{ENV['HOME']}/.busbar".freeze
TEST_KUBECTL_LOCAL_FOLDER = "#{ENV['HOME']}/.kube".freeze
TEST_KUBECTL_LOCAL_BIN_FOLDER = "#{TEST_KUBECTL_LOCAL_FOLDER}/bin".freeze

FileUtils.mkdir_p(TEST_BUSBAR_LOCAL_FOLDER) unless Dir.exist?(TEST_BUSBAR_LOCAL_FOLDER)
FileUtils.mkdir_p(TEST_KUBECTL_LOCAL_FOLDER) unless Dir.exist?(TEST_KUBECTL_LOCAL_FOLDER)
FileUtils.mkdir_p(TEST_KUBECTL_LOCAL_BIN_FOLDER) unless Dir.exist?(TEST_KUBECTL_LOCAL_BIN_FOLDER)

TEST_BUSBAR_CONFIG_FILE_PATH = "#{TEST_BUSBAR_LOCAL_FOLDER}/config".freeze
TEST_KUBECTL_CONFIG_FILE = "#{TEST_KUBECTL_LOCAL_FOLDER}/config".freeze
TEST_KUBECTL_CONFIG_VERSION_FILE = "#{TEST_KUBECTL_LOCAL_FOLDER}/config_version".freeze
TEST_KUBECTL = "#{TEST_KUBECTL_LOCAL_BIN_FOLDER}/kubectl-#{VERSION}.#{KUBECTL_PATCH_VERSION}".freeze

busbar_config_hash = {
  busbar_api_url: 'http://busbar.fake.profile',
  default_git_branch: 'default_git_branch',
  kubectl_config_url: 'kubectl_config_url',
  kubectl_config_version_url: 'kubectl_config_version_url',
  busbar_profile: 'busbar_profile'
}
busbar_string_key_hash = {}

kubectl_config_hash = {
  name: 'test.profile'
}
kubectl_string_key_hash = {}

busbar_config_hash.each { |k, v| busbar_string_key_hash[k.to_s] = v }
kubectl_config_hash.each { |k, v| kubectl_string_key_hash[k.to_s] = v }

File.open(TEST_BUSBAR_CONFIG_FILE_PATH, 'w') { |f| f.write(busbar_string_key_hash.to_yaml) }
File.open(TEST_KUBECTL_CONFIG_FILE, 'w') { |f| f.write(kubectl_string_key_hash.to_yaml) }
File.open(TEST_KUBECTL_CONFIG_VERSION_FILE, 'w') { |f| f.write(' ') }
File.open(TEST_KUBECTL, 'w') { |f| f.write(' ') }

require_relative '../lib/busbar_cli'

require 'simplecov'
SimpleCov.start

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

# WebMock.disable_net_connect!(allow_localhost: true)

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:each) do
    stub_const('CONFIG_FILE_PATH', TEST_APP_CONFIG_FILE_PATH)
    stub_const('BUSBAR_CONFIG_FILE_PATH', TEST_BUSBAR_CONFIG_FILE_PATH)
  end

  config.after(:each) do
    FileUtils.rm(TEST_APP_CONFIG_FILE_PATH) if File.exist?(TEST_APP_CONFIG_FILE_PATH)
  end

  config.after(:suite) do
    # Remove mocked config file
    FileUtils.rm(TEST_BUSBAR_CONFIG_FILE_PATH) if File.exist?(TEST_BUSBAR_CONFIG_FILE_PATH)
    FileUtils.rm_rf(TEST_BUSBAR_LOCAL_FOLDER) if File.exist?(TEST_BUSBAR_LOCAL_FOLDER)
    FileUtils.rm_rf(TEST_KUBECTL_LOCAL_FOLDER) if File.exist?(TEST_KUBECTL_LOCAL_FOLDER)
  end

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
    # else
    # Print the 10 slowest examples and example groups at the
    # end of the spec run, to help surface which specs are running
    # particularly slow.
    # config.profile_examples = 10
  end
end

RSpec::Matchers.define :exit_with_code do |exp_code|
  actual = nil
  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual && actual == exp_code
  end
  failure_message do
    "expected block to call exit(#{exp_code}) but exit" +
      (actual.nil? ? ' not called' : "(#{actual}) was called")
  end
  failure_message_when_negated do
    "expected block not to call exit(#{exp_code})"
  end
  description do
    "expect block to call exit(#{exp_code})"
  end
end
