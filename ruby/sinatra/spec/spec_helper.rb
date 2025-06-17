# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

# Setup SimpleCov for coverage reporting
if ENV['COVERAGE']
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
  
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
    add_filter '/config/'
    add_group 'Controllers', 'app/controllers'
    add_group 'Models', 'app/models'
    add_group 'Services', 'app/services'
    add_group 'Serializers', 'app/serializers'
  end
end

ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec'
require 'factory_bot'
require 'faker'
require 'database_cleaner-sequel'
require 'json'
require 'webmock/rspec'

# Load the application
require_relative '../config/application'

# Disable HTTP requests during tests
WebMock.disable_net_connect!(allow_localhost: true)

# Configure RSpec
RSpec.configure do |config|
  # Include test helpers
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  # Database cleaner setup
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Reset WebMock after each test
  config.after(:each) do
    WebMock.reset!
  end

  # Use expect syntax instead of should
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  # Mock framework configuration
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Shared context for all tests
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Focus on specific tests
  config.filter_run_when_matching :focus

  # Randomize test order
  config.order = :random
  Kernel.srand config.seed

  # Output configuration
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!

  # Warnings configuration
  config.warnings = true

  # Profile slow tests
  config.profile_examples = 10 if ENV['PROFILE']

  # Custom formatters
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end
end

# Helper method for Rack::Test
def app
  SinatraAPI::Application
end

# Helper methods for testing
module TestHelpers
  def json_response
    JSON.parse(last_response.body)
  end

  def auth_headers(user = nil)
    user ||= create(:user)
    token = generate_jwt_token(user)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: Time.now.to_i + 3600 # 1 hour
    }
    JWT.encode(payload, ENV.fetch('JWT_SECRET', 'test-secret'), 'HS256')
  end

  def api_post(path, params = {}, headers = {})
    post path, params.to_json, headers.merge('CONTENT_TYPE' => 'application/json')
  end

  def api_put(path, params = {}, headers = {})
    put path, params.to_json, headers.merge('CONTENT_TYPE' => 'application/json')
  end

  def api_patch(path, params = {}, headers = {})
    patch path, params.to_json, headers.merge('CONTENT_TYPE' => 'application/json')
  end

  def expect_success_response(status = 200)
    expect(last_response.status).to eq(status)
    expect(json_response['success']).to be true
    expect(json_response).to have_key('timestamp')
  end

  def expect_error_response(status = 400, error_message = nil)
    expect(last_response.status).to eq(status)
    expect(json_response['success']).to be false
    expect(json_response).to have_key('error')
    expect(json_response).to have_key('timestamp')
    expect(json_response['error']).to eq(error_message) if error_message
  end

  def expect_json_response
    expect(last_response.content_type).to include('application/json')
  end
end

# Include test helpers in RSpec
RSpec.configure do |config|
  config.include TestHelpers
end

# Load factory definitions
Dir[File.join(__dir__, 'factories', '**', '*.rb')].each { |f| require f }

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f } 