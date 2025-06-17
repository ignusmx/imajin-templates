# frozen_string_literal: true

require 'bcrypt'

class User < Sequel::Model
  plugin :validation_helpers
  plugin :json_serializer
  
  # Associations
  # one_to_many :posts (example)
  
  def validate
    super
    validates_presence [:email, :password_digest]
    validates_unique :email
    validates_format(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, :email, message: 'is not a valid email')
    validates_min_length 8, :password if password
  end

  def before_create
    super
    self.created_at = Time.now
    self.updated_at = Time.now
  end

  def before_update
    super
    self.updated_at = Time.now
  end

  # Password handling
  def password=(new_password)
    @password = new_password
    self.password_digest = BCrypt::Password.create(new_password)
  end

  def password
    @password
  end

  def authenticate(password)
    BCrypt::Password.new(password_digest) == password
  end

  # JSON serialization
  def to_json_hash
    {
      id: id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  # Class methods
  def self.authenticate(email, password)
    user = first(email: email)
    user&.authenticate(password) ? user : nil
  end

  def self.create_with_password(params)
    user = new(params.except('password'))
    user.password = params['password'] if params['password']
    user.save
    user
  end
end 