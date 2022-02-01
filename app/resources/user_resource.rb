# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  first_name        :string           not null
#  last_name         :string           not null
#  email             :string           default(""), not null
#  phone_number      :string           not null
#  gender            :string           default("other"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  requested_zipcode :string
#
# Indexes
#
#  index_users_on_email         (email) UNIQUE
#  index_users_on_gender        (gender)
#  index_users_on_phone_number  (phone_number) UNIQUE
#
class UserResource < ApplicationResource
  self.model = User
  self.type = :users

  primary_endpoint 'users', [:index, :show, :create, :update]

  has_many :properties
  has_many :devices

  attribute :id,           :uuid
  attribute :first_name,   :string, sortable: false
  attribute :last_name,    :string, sortable: false
  attribute :phone_number, :string
  attribute :email,        :string
  attribute :gender,       :string_enum, allow: ['male', 'female', 'other']
  attribute :password,     :string,      readable: false

  attribute :requested_zipcode, :string, readable: false

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
