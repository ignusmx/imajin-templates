# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Authentication API', type: :request do
  let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
  
  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      it 'returns success with token and user data' do
        api_post '/api/v1/auth/login', {
          email: user.email,
          password: 'password123'
        }

        expect_success_response
        expect(json_response['data']).to have_key('token')
        expect(json_response['data']).to have_key('user')
        expect(json_response['data']).to have_key('expires_in')
        expect(json_response['data']['user']['email']).to eq(user.email)
        expect(json_response['data']).not_to have_key('password_digest')
      end
    end

    context 'with invalid email' do
      it 'returns authentication error' do
        api_post '/api/v1/auth/login', {
          email: 'nonexistent@example.com',
          password: 'password123'
        }

        expect_error_response(401, 'Invalid credentials')
      end
    end

    context 'with invalid password' do
      it 'returns authentication error' do
        api_post '/api/v1/auth/login', {
          email: user.email,
          password: 'wrongpassword'
        }

        expect_error_response(401, 'Invalid credentials')
      end
    end

    context 'with missing credentials' do
      it 'returns validation error for missing email' do
        api_post '/api/v1/auth/login', {
          password: 'password123'
        }

        expect_error_response(400, 'Email and password are required')
      end

      it 'returns validation error for missing password' do
        api_post '/api/v1/auth/login', {
          email: user.email
        }

        expect_error_response(400, 'Email and password are required')
      end
    end

    context 'with invalid JSON' do
      it 'returns JSON parsing error' do
        post '/api/v1/auth/login', 'invalid json', {
          'CONTENT_TYPE' => 'application/json'
        }

        expect_error_response(400, 'Invalid JSON in request body')
      end
    end
  end

  describe 'POST /api/v1/auth/refresh' do
    context 'with valid token' do
      it 'returns new token' do
        api_post '/api/v1/auth/refresh', {}, auth_headers(user)

        expect_success_response
        expect(json_response['data']).to have_key('token')
        expect(json_response['data']).to have_key('user')
        expect(json_response['data']['user']['email']).to eq(user.email)
      end
    end

    context 'without token' do
      it 'returns authentication error' do
        api_post '/api/v1/auth/refresh'

        expect_error_response(401, 'Authentication required')
      end
    end

    context 'with invalid token' do
      it 'returns authentication error' do
        api_post '/api/v1/auth/refresh', {}, {
          'HTTP_AUTHORIZATION' => 'Bearer invalid_token'
        }

        expect_error_response(401, 'Authentication required')
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    context 'with valid token' do
      it 'returns success' do
        delete '/api/v1/auth/logout', {}, auth_headers(user)

        expect_success_response
        expect(json_response['message']).to eq('Logout successful')
      end
    end

    context 'without token' do
      it 'still returns success (JWT is stateless)' do
        delete '/api/v1/auth/logout'

        expect_success_response
        expect(json_response['message']).to eq('Logout successful')
      end
    end
  end
end 