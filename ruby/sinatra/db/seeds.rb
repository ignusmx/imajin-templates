# frozen_string_literal: true

require_relative '../config/application'

# Clear existing data (development only)
if ENV['RACK_ENV'] == 'development'
  puts 'Clearing existing data...'
  User.truncate
end

# Create sample users
puts 'Creating sample users...'

# Admin user
admin = User.create_with_password(
  email: 'admin@example.com',
  password: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin',
  phone: '+1-555-0001'
)

# Regular users
users_data = [
  {
    email: 'john.doe@example.com',
    password: 'password123',
    first_name: 'John',
    last_name: 'Doe',
    phone: '+1-555-0101',
    date_of_birth: Date.new(1990, 5, 15)
  },
  {
    email: 'jane.smith@example.com',
    password: 'password123',
    first_name: 'Jane',
    last_name: 'Smith',
    phone: '+1-555-0102',
    date_of_birth: Date.new(1985, 8, 22)
  },
  {
    email: 'bob.wilson@example.com',
    password: 'password123',
    first_name: 'Bob',
    last_name: 'Wilson',
    phone: '+1-555-0103',
    date_of_birth: Date.new(1992, 12, 3)
  },
  {
    email: 'alice.johnson@example.com',
    password: 'password123',
    first_name: 'Alice',
    last_name: 'Johnson',
    phone: '+1-555-0104',
    date_of_birth: Date.new(1988, 3, 10)
  }
]

users_data.each do |user_data|
  User.create_with_password(user_data)
end

puts "Created #{User.count} users:"
puts "- Admin: admin@example.com / password123"
puts "- Users: john.doe@example.com, jane.smith@example.com, bob.wilson@example.com, alice.johnson@example.com"
puts "- All users have password: password123"
puts ""
puts "You can login with any of these credentials to test the API:"
puts ""
puts "curl -X POST http://localhost:4567/api/v1/auth/login \\"
puts "  -H 'Content-Type: application/json' \\"
puts "  -d '{\"email\":\"admin@example.com\",\"password\":\"password123\"}'"
puts ""
puts "Database seeded successfully! 🌱" 