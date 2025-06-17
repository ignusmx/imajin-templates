# frozen_string_literal: true

require_relative 'base_controller'

class AuthController < BaseController
  def login(request, params)
    @request = request
    @params = params
    
    # Get JSON body
    body = validate_json_body
    email = body['email']
    password = body['password']
    
    return error_response('Email and password are required', status: 400) unless email && password
    
    # Authenticate user
    user = User.authenticate(email, password)
    return error_response('Invalid credentials', status: 401) unless user
    
    # Generate JWT token
    token = generate_jwt_token(user)
    
    success_response(
      {
        token: token,
        user: user.to_json_hash,
        expires_in: ENV.fetch('JWT_EXPIRATION', '86400').to_i
      },
      message: 'Login successful'
    )
  end

  def refresh(request, params)
    @request = request
    @params = params
    
    current_user = require_authentication!
    
    # Generate new token
    token = generate_jwt_token(current_user)
    
    success_response(
      {
        token: token,
        user: current_user.to_json_hash,
        expires_in: ENV.fetch('JWT_EXPIRATION', '86400').to_i
      },
      message: 'Token refreshed successfully'
    )
  end

  def logout(request, params)
    @request = request
    @params = params
    
    # For JWT, we don't need to do anything server-side
    # The client should discard the token
    # In a more sophisticated setup, you might maintain a blacklist of tokens
    
    success_response(
      {},
      message: 'Logout successful'
    )
  end

  private

  def generate_jwt_token(user)
    payload = {
      user_id: user.id,
      email: user.email,
      exp: Time.now.to_i + ENV.fetch('JWT_EXPIRATION', '86400').to_i
    }
    
    JWT.encode(payload, ENV.fetch('JWT_SECRET'), 'HS256')
  end
end 