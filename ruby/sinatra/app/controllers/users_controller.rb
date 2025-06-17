# frozen_string_literal: true

require_relative 'base_controller'

class UsersController < BaseController
  def index(request, params)
    @request = request
    @params = params
    
    pagination = pagination_params
    
    # Get users with pagination
    users = User.limit(pagination[:per_page]).offset((pagination[:page] - 1) * pagination[:per_page])
    total_users = User.count
    
    # Serialize users
    users_data = users.map(&:to_json_hash)
    
    paginated_response(
      users_data,
      page: pagination[:page],
      per_page: pagination[:per_page],
      total: total_users
    )
  end

  def show(request, params)
    @request = request
    @params = params
    
    user = User[params['id']]
    return error_response('User not found', status: 404) unless user
    
    success_response(user.to_json_hash)
  end

  def create(request, params)
    @request = request
    @params = params
    
    # Get JSON body
    body = validate_json_body
    
    # Validate required fields
    required_fields = %w[email password first_name last_name]
    missing_fields = required_fields.select { |field| body[field].nil? || body[field].empty? }
    
    if missing_fields.any?
      return error_response(
        'Missing required fields',
        details: "Required fields: #{missing_fields.join(', ')}",
        status: 400
      )
    end
    
    begin
      user = User.create_with_password(body)
      success_response(
        user.to_json_hash,
        message: 'User created successfully',
        status: 201
      )
    rescue Sequel::ValidationFailed => e
      error_response(
        'Validation failed',
        details: e.errors,
        status: 422
      )
    rescue Sequel::UniqueConstraintViolation
      error_response(
        'User with this email already exists',
        status: 409
      )
    end
  end

  def update(request, params)
    @request = request
    @params = params
    
    user = User[params['id']]
    return error_response('User not found', status: 404) unless user
    
    # Get JSON body
    body = validate_json_body
    
    # Remove password from direct assignment (handle separately)
    password = body.delete('password')
    
    begin
      user.update(body)
      user.password = password if password && !password.empty?
      user.save
      
      success_response(
        user.to_json_hash,
        message: 'User updated successfully'
      )
    rescue Sequel::ValidationFailed => e
      error_response(
        'Validation failed',
        details: e.errors,
        status: 422
      )
    rescue Sequel::UniqueConstraintViolation
      error_response(
        'User with this email already exists',
        status: 409
      )
    end
  end

  def destroy(request, params)
    @request = request
    @params = params
    
    user = User[params['id']]
    return error_response('User not found', status: 404) unless user
    
    begin
      user.destroy
      success_response(
        {},
        message: 'User deleted successfully'
      )
    rescue Sequel::Error => e
      error_response(
        'Failed to delete user',
        details: e.message,
        status: 500
      )
    end
  end
end 