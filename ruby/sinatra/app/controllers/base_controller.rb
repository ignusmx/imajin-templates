# frozen_string_literal: true

class BaseController
  attr_reader :request, :params

  def initialize
    @request = nil
    @params = {}
  end

  protected

  # JSON response helpers
  def json_response(data, status: 200)
    content_type 'application/json'
    status status
    Oj.dump(data, mode: :compat)
  end

  def success_response(data = {}, message: 'Success', status: 200)
    json_response({
      success: true,
      message: message,
      data: data,
      timestamp: Time.now.iso8601
    }, status: status)
  end

  def error_response(message, details: nil, status: 400)
    response = {
      success: false,
      error: message,
      timestamp: Time.now.iso8601
    }
    response[:details] = details if details
    
    json_response(response, status: status)
  end

  def paginated_response(collection, page: 1, per_page: 20, total: nil)
    total ||= collection.respond_to?(:count) ? collection.count : collection.size
    
    json_response({
      success: true,
      data: collection,
      pagination: {
        page: page.to_i,
        per_page: per_page.to_i,
        total: total,
        pages: (total.to_f / per_page.to_i).ceil
      },
      timestamp: Time.now.iso8601
    })
  end

  # Parameter handling
  def extract_params(*keys)
    params.select { |k, _| keys.include?(k.to_s) || keys.include?(k.to_sym) }
  end

  def require_params(*keys)
    missing = keys.select { |key| params[key.to_s].nil? && params[key.to_sym].nil? }
    return if missing.empty?
    
    halt 400, error_response("Missing required parameters: #{missing.join(', ')}")
  end

  # Pagination parameters
  def pagination_params
    {
      page: [params.fetch('page', 1).to_i, 1].max,
      per_page: [[params.fetch('per_page', 20).to_i, 1].max, 100].min
    }
  end

  # JWT token helpers
  def current_user_from_token
    return nil unless request.env['HTTP_AUTHORIZATION']
    
    token = request.env['HTTP_AUTHORIZATION'].split(' ').last
    return nil unless token
    
    begin
      decoded = JWT.decode(token, ENV.fetch('JWT_SECRET'), true, algorithm: 'HS256')
      user_id = decoded[0]['user_id']
      User[user_id]
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  def require_authentication!
    user = current_user_from_token
    return user if user
    
    halt 401, error_response('Authentication required', status: 401)
  end

  # Validation helpers
  def validate_json_body
    body_content = request.body.read
    return {} if body_content.empty?
    
    JSON.parse(body_content)
  rescue JSON::ParserError
    halt 400, error_response('Invalid JSON in request body')
  end

  # Logging helper
  def log_request
    logger.info "#{request.request_method} #{request.path_info} - #{request.ip}" if defined?(logger)
  end

  private

  def halt(status, body)
    throw :halt, [status, {'Content-Type' => 'application/json'}, body]
  end

  def content_type(type)
    # This would be handled by Sinatra in the actual context
  end

  def status(code)
    # This would be handled by Sinatra in the actual context
  end
end 