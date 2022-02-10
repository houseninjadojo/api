# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  first_name             :string           not null
#  last_name              :string           not null
#  email                  :string           default(""), not null
#  phone_number           :string           not null
#  gender                 :string           default("other"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  requested_zipcode      :string
#  auth_zero_user_created :boolean          default(FALSE)
#  stripe_customer_id     :string
#  hubspot_id             :string
#  hubspot_contact_object :jsonb
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_gender              (gender)
#  index_users_on_hubspot_id          (hubspot_id) UNIQUE
#  index_users_on_phone_number        (phone_number) UNIQUE
#  index_users_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#

class UserResource < ApplicationResource
  self.model = User
  self.type = :users

  primary_endpoint 'users', [:index, :show, :create, :update]

  has_many :devices
  has_many :invoices
  has_many :payment_methods
  has_many :properties
  has_one  :subscription

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
