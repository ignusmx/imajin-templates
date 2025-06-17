# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    role { 'user' }
    active { true }
    password { 'password123' }
    
    # Manually set timestamps to avoid Sequel auto-timestamping issues
    created_at { Time.now }
    updated_at { Time.now }

    trait :admin do
      role { 'admin' }
    end

    trait :inactive do
      active { false }
    end

    trait :with_phone do
      phone { '+1-555-0199' }
    end

    trait :without_phone do
      phone { nil }
    end

    # Custom factory methods
    factory :admin_user, traits: [:admin]
    factory :inactive_user, traits: [:inactive]
    factory :user_with_phone, traits: [:with_phone]
  end
end 