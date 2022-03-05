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
#  promo_code_id          :uuid
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_gender              (gender)
#  index_users_on_hubspot_id          (hubspot_id) UNIQUE
#  index_users_on_phone_number        (phone_number) UNIQUE
#  index_users_on_promo_code_id       (promo_code_id)
#  index_users_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#
class User < ApplicationRecord
  encrypts :hubspot_contact_object

  # Callbacks
  after_create_commit :create_stripe_customer,
    unless: :should_not_create_stripe_customer?

  after_create_commit :create_hubspot_contact,
    unless: :should_not_create_hubspot_contact?

  after_save :create_auth_user,
    if:     -> (user) { user.password.present? },
    unless: :should_not_create_auth_user?

  # after_update_commit :update_stripe_customer,
  #   if:     -> (user) { user.stripe_customer_id.present? },
  #   unless: :should_not_sync_user?

  # after_update_commit :update_auth_user,
  #   if:     -> (user) { user.auth_zero_user_created == true },
  #   unless: :should_not_sync_user?

  after_destroy_commit :delete_auth_user,
    if: -> (user) { user.auth_zero_user_created == true }

  after_destroy_commit :delete_stripe_customer,
    if: -> (user) { user.stripe_customer_id.present? }

  # Associations
  has_many   :devices
  has_many   :documents
  has_many   :invoices
  has_many   :payment_methods
  has_many   :payments
  has_many   :properties
  has_one    :subscription
  belongs_to :promo_code, required: false

  # Validations
  validates :first_name,         presence: true
  validates :last_name,          presence: true
  validates :email,              presence: true, uniqueness: true
  validates :phone_number,       presence: true, phone: true
  validates :gender,             inclusion: { in: %w(male female other) }
  validates :stripe_customer_id, uniqueness: true, allow_nil: true
  validates :hubspot_id,         uniqueness: true, allow_nil: true

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

  # intercom hash
  def intercom_hash
    Rails.cache.fetch("user:#{self.id}:intercom_hash", expires_in: 1.day) do
      OpenSSL::HMAC.hexdigest(
        'sha256', # hash function
        Rails.secrets.dig(:intercom, :identity_verification_secret, :ios), # secret key (keep safe!)
        self.id.to_s # user's id
      )
    end
  end

  # no-op
  # needs to exist, otherwise we get a 400 error
  def intercom_hash=(val)
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

  def create_hubspot_contact
    Hubspot::CreateContactJob.perform_later(self)
  end

  def update_hubspot_contact
    Hubspot::UpdateContactJob.perform_later(self)
  end

  # sync gates

  def should_not_create_auth_user?
    self.auth_zero_user_created == true
  end

  def should_not_create_stripe_customer?
    self.stripe_customer_id.present?
  end

  def should_not_create_hubspot_contact?
    self.hubspot_id.present?
  end

  # sync

  def sync_flag
    Kredis.flag("user:sync:#{self.id}")
  end

  def mark_sync_flag!
    sync_flag.mark(expires_in: 1.minute)
  end

  def update_from_service(service, payload)
    if sync_flag.marked?
      return # we already updated
    else
      mark_sync_flag!
    end

    User.transaction do
      payload.each do |k, v|
        update_attribute(k, v)
      end
    end

    case service
    when "hubspot"
      update_auth_user
      update_stripe_customer
    when "stripe"
      update_auth_user
      update_hubspot_contact
    when "auth0"
      update_stripe_customer
      update_hubspot_contact
    end
  end
end
