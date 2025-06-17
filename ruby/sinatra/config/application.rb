# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require 'jwt'
require 'bcrypt'
require 'oj'
require 'dotenv/load'

# Load database configuration
require_relative 'database'

# Load all application files
Dir[File.join(__dir__, '..', 'app', '**', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, '..', 'lib', '**', '*.rb')].each { |file| require file }

module SinatraAPI
  class Application < Sinatra::Base
    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
      also_reload 'app/**/*.rb'
      also_reload 'lib/**/*.rb'
      also_reload 'config/**/*.rb'
    end

    configure do
      enable :logging, :method_override
      set :show_exceptions, false
      set :raise_errors, false
      set :dump_errors, false
      
      # JSON configuration
      set :default_content_type, 'application/json'
      
      # CORS headers
      before do
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        headers['Access-Control-Max-Age'] = '86400'
      end
      
      # Handle preflight requests
      options '*' do
        response.headers['Allow'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Authorization'
        200
      end
    end

    # Global error handlers
    error Sequel::ValidationFailed do
      status 422
      json error: 'Validation failed', details: env['sinatra.error'].errors
    end

    error Sequel::NoMatchingRow do
      status 404
      json error: 'Resource not found'
    end

    error Sequel::UniqueConstraintViolation do
      status 409
      json error: 'Resource already exists'
    end

    error JWT::DecodeError, JWT::ExpiredSignature do
      status 401
      json error: 'Invalid or expired token'
    end

    not_found do
      json error: 'Endpoint not found'
    end

    error do
      status 500
      if ENV['RACK_ENV'] == 'development'
        json error: 'Internal server error', details: env['sinatra.error'].message
      else
        json error: 'Internal server error'
      end
    end

    # Health check endpoint
    get '/health' do
      json status: 'ok', timestamp: Time.now.iso8601
    end

    # API routes
    register Sinatra::Namespace

    namespace ENV.fetch('API_BASE_PATH', '/api') do
      namespace "/#{ENV.fetch('API_VERSION', 'v1')}" do
        # Health check
        get '/health' do
          json(
            status: 'ok',
            timestamp: Time.now.iso8601,
            version: ENV.fetch('API_VERSION', 'v1'),
            environment: ENV.fetch('RACK_ENV', 'development')
          )
        end

        # Authentication routes
        post '/auth/login' do
          AuthController.new.login(request, params)
        end

        post '/auth/refresh' do
          AuthController.new.refresh(request, params)
        end

        delete '/auth/logout' do
          AuthController.new.logout(request, params)
        end

        # Protected user routes
        namespace '/users' do
          before do
            @current_user = authenticate_request!
          end

          get '' do
            UsersController.new.index(request, params)
          end

          post '' do
            UsersController.new.create(request, params)
          end

          get '/:id' do
            UsersController.new.show(request, params)
          end

          put '/:id' do
            UsersController.new.update(request, params)
          end

          delete '/:id' do
            UsersController.new.destroy(request, params)
          end
        end
      end
    end

    # Swagger/OpenAPI documentation
    if ENV.fetch('ENABLE_SWAGGER_DOCS', 'true') == 'true'
      get '/docs' do
        erb :swagger
      end

      get '/openapi.json' do
        content_type 'application/json'
        File.read(File.join(__dir__, '..', 'docs', 'openapi.json'))
      end
    end

    private

    def authenticate_request!
      header = request.env['HTTP_AUTHORIZATION']
      return unauthorized! unless header

      token = header.split(' ').last
      return unauthorized! unless token

      begin
        decoded = JWT.decode(token, ENV.fetch('JWT_SECRET'), true, algorithm: 'HS256')
        user_id = decoded[0]['user_id']
        user = User[user_id]
        return unauthorized! unless user
        
        user
      rescue JWT::DecodeError, JWT::ExpiredSignature
        unauthorized!
      end
    end

    def unauthorized!
      halt 401, json(error: 'Unauthorized')
    end
  end
end 