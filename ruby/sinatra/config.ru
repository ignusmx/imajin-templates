# frozen_string_literal: true

require 'dotenv/load'
require 'rack/cors'
require_relative 'config/application'

# Enable request logging in development
use Rack::CommonLogger if ENV['RACK_ENV'] == 'development'

# Security middleware
use Rack::Protection

# CORS middleware
use Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3000,http://localhost:4567').split(',')
    resource '*',
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: ENV.fetch('CORS_ALLOW_CREDENTIALS', 'true') == 'true'
  end
end

run SinatraAPI::Application 