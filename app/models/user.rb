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
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_gender              (gender)
#  index_users_on_phone_number        (phone_number) UNIQUE
#  index_users_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#
class User < ApplicationRecord
  # Callbacks
  after_create_commit :create_stripe_customer,
    unless: -> (user) { user.stripe_customer_id.present? }

  after_update_commit :update_stripe_customer,
    if:     -> (user) { user.stripe_customer_id.present? },
    unless: -> (user) { user.saved_change_to_attribute?(:stripe_customer_id) }

  after_save :create_auth_user,
    if:     -> (user) { user.password.present? },
    unless: -> (user) { user.auth_zero_user_created == true }

  after_update_commit :update_auth_user,
    if:     -> (user) { user.auth_zero_user_created == true },
    unless: -> (user) { user.saved_changes.keys.intersect? ["stripe_customer_id", "auth_zero_user_created"] }

  after_destroy_commit :delete_auth_user
  after_destroy_commit :delete_stripe_customer

  # Associations
  has_many :devices
  has_many :payment_methods
  has_many :properties

  # Validations
  validates :first_name,         presence: true
  validates :last_name,          presence: true
  validates :email,              presence: true, uniqueness: true
  validates :phone_number,       presence: true, phone: true
  validates :gender,             inclusion: { in: %w(male female other) }
  validates :stripe_customer_id, uniqueness: true, allow_nil: true

  # Temporary password token management
  # VGS Volatile tokens expire in 1 hour
  attr_reader :_password

  def password=(val)
    @_password = Kredis.string("#{self.id}:tmp:password_token", expires_in: 1.hour)
    @_password.value = val
  end

  def password
    @_password ||= Kredis.string("#{self.id}:tmp:password_token")
    @_password&.value
  end

  # Get the user's default property
  #
  # @return {Property}
  def default_property
    self.properties.first
  end

  # User Full Name (first_name + last_name)
  #
  # @return {string} full name
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  alias name full_name

  # Auth Service ID
  #
  # @return {string} auth id
  def auth_id
    "auth0|#{self.id}"
  end

  # Callbacks

  def create_auth_user
    Auth::CreateUserJob.perform_later(self)
  end

  def update_auth_user
    Auth::UpdateUserJob.perform_later(self)
  end

  def delete_auth_user
    Auth::DeleteUserJob.perform_later(auth_id)
  end

  def create_stripe_customer
    Stripe::CreateCustomerJob.perform_later(self)
  end

  def update_stripe_customer
    Stripe::UpdateCustomerJob.perform_later(self)
  end

  def delete_stripe_customer
    Stripe::DeleteCustomerJob.perform_later(stripe_customer_id)
  end
end
