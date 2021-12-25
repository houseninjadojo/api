class UserResource < ApplicationResource
  self.model = User
  self.type = :users

  primary_endpoint 'users', [:index, :show, :create, :update]

  has_many :properties

  attribute :id,           :uuid
  attribute :first_name,   :string
  attribute :last_name,    :string
  attribute :phone_number, :string
  attribute :email,        :string
  attribute :gender,       :string_enum, allow: ['male', 'female', 'other']
  attribute :password,     :string,      only: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
