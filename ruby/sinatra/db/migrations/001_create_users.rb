# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :email, null: false, unique: true
      String :password_digest, null: false
      String :first_name, null: false
      String :last_name, null: false
      String :phone
      Date :date_of_birth
      String :role, default: 'user'
      Boolean :active, default: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      
      index :email, unique: true
      index :role
      index :active
      index :created_at
    end
  end

  down do
    drop_table(:users)
  end
end 