# frozen_string_literal: true

require 'sequel'
require 'logger'

# Database configuration
DATABASE_URL = if ENV['RACK_ENV'] == 'test'
                 ENV.fetch('TEST_DATABASE_URL', 'postgresql://localhost/sinatra_api_test')
               else
                 ENV.fetch('DATABASE_URL', 'postgresql://localhost/sinatra_api_development')
               end

# Connect to database with additional options
DB = Sequel.connect(DATABASE_URL, 
                    max_connections: 10,
                    pool_timeout: 10,
                    test: false) # Don't test connection on startup

# Configure logging
if ENV['RACK_ENV'] == 'development'
  DB.loggers << Logger.new($stdout)
end

# Load Sequel extensions
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :auto_validations

# Global model settings
Sequel::Model.strict_param_setting = false
Sequel::Model.plugin :forbid_lazy_load

# Freeze model classes after loading
Sequel::Model.freeze_descendents unless ENV['RACK_ENV'] == 'development' 