# == Schema Information
#
# Table name: users
#
#  id                                        :uuid             not null, primary key
#  auth_zero_user_created                    :boolean          default(FALSE)
#  contact_type                              :string           default("Customer")
#  email(Email Address)                      :string           default(""), not null
#  first_name(First Name)                    :string           not null
#  gender(Gender)                            :string           default("other"), not null
#  hubspot_contact_object                    :jsonb
#  last_name(Last Name)                      :string           not null
#  onboarding_code                           :string
#  onboarding_link                           :string
#  onboarding_step                           :string
#  phone_number(Phone Number (+15555555555)) :string           not null
#  requested_zipcode                         :string
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  arrivy_id                                 :string
#  hubspot_id                                :string
#  promo_code_id                             :uuid
#  stripe_id                                 :string
#
# Indexes
#
#  index_users_on_arrivy_id        (arrivy_id) UNIQUE
#  index_users_on_email            (email) UNIQUE
#  index_users_on_gender           (gender)
#  index_users_on_hubspot_id       (hubspot_id) UNIQUE
#  index_users_on_onboarding_code  (onboarding_code) UNIQUE
#  index_users_on_phone_number     (phone_number) UNIQUE
#  index_users_on_promo_code_id    (promo_code_id)
#  index_users_on_stripe_id        (stripe_id) UNIQUE
#
class User < ApplicationRecord
  encrypts :hubspot_contact_object

  # callbacks

  before_create :generate_onboarding_code
  before_create :set_onboarding_step

  before_save :set_contact_type

  after_create_commit :generate_onboarding_link

  after_save :complete_onboarding,
    if: -> (user) { user.onboarding_step == OnboardingStep::SET_PASSWORD }

  after_save_commit    :sync_create!
  after_update_commit  :sync_update!
  # after_destroy_commit :sync_delete!

  # associations

  has_many   :devices
  has_many   :documents
  has_many   :document_groups
  has_many   :invoices
  has_many   :payment_methods
  has_many   :payments
  has_many   :properties
  has_one    :subscription
  belongs_to :promo_code, required: false

  # validations

  validates :first_name,      presence: true
  validates :last_name,       presence: true
  validates :email,           presence: true, uniqueness: true
  validates :phone_number,    presence: true, uniqueness: true, phone: true
  validates :gender,          inclusion: { in: %w(male female other) }
  validates :stripe_id,       uniqueness: true, allow_nil: true
  validates :hubspot_id,      uniqueness: true, allow_nil: true
  validates :onboarding_code, uniqueness: true, allow_nil: true
  validates :contact_type,    inclusion: { in: ContactType::ALL }
  validates :onboarding_step, inclusion: { in: OnboardingStep::ALL }, allow_nil: true

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

  # Get the user's default payment method
  #
  # @return {PaymentMethod}
  def default_payment_method
    self.payment_methods.first
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

  # gates

  def has_completed_onboarding?
    onboarding_step == "completed"
  end

  def is_currently_onboarding?
    !has_completed_onboarding? && contact_type == ContactType::CUSTOMER
  end

  def is_subscribed?
    self.subscription.present? && self.subscription.is_subscribed?
  end

  # no-op
  # needs to exist, otherwise we get a 400 error
  def intercom_hash=(val)
  end

  # callbacks

  def generate_onboarding_code
    self.onboarding_code = SecureRandom.hex(12)
  end

  def generate_onboarding_link
    return if onboarding_link.present?
    Users::GenerateOnboardingLinkJob.perform_later(self)
  end

  def complete_onboarding
    self.onboarding_step = 'completed'
    self.onboarding_code = nil
    self.onboarding_link = nil
    self.save
  end

  def set_onboarding_step
    if self.onboarding_step.present?
      return
    elsif [self.email, self.phone_number, self.first_name, self.last_name].all?(&:present?)
      self.onboarding_step = OnboardingStep::CONTACT_INFO
    end
  end

  def set_contact_type
    if self.requested_zipcode.present?
      self.contact_type = ContactType::SERVICE_AREA_REQUESTED
    else
      self.contact_type ||= ContactType::CUSTOMER
    end
  end

  # sync

  include Syncable

  def sync_services
    [
      # :arrivy,
      :auth0,
      :hubspot,
      :stripe,
    ]
  end

  def sync_actions
    [
      :create,
      :update,
      # :delete,
    ]
  end

  # @todo clean this up
  def sync_delete!
    Auth::DeleteUserJob.perform_later(auth_id)
    Stripe::DeleteCustomerJob.perform_later(stripe_id)
  end
end
