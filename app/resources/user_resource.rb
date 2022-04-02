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
#  contact_type           :string
#  onboarding_step        :string
#  onboarding_code        :string
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_gender              (gender)
#  index_users_on_hubspot_id          (hubspot_id) UNIQUE
#  index_users_on_onboarding_code     (onboarding_code) UNIQUE
#  index_users_on_phone_number        (phone_number) UNIQUE
#  index_users_on_promo_code_id       (promo_code_id)
#  index_users_on_stripe_customer_id  (stripe_customer_id) UNIQUE
#

class UserResource < ApplicationResource
  self.model = User
  self.type = :users

  primary_endpoint 'users', [:index, :show, :create, :update]

  has_many   :devices
  has_many   :documents
  has_many   :invoices
  has_many   :payment_methods
  has_many   :payments
  has_many   :properties
  has_one    :subscription
  belongs_to :promo_code

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

  attribute :intercom_hash, :string, except: [:writeable]

  # attribute :intercom_hash, :string, only: [:readable, :writeable] do
  #   unless @object.devices.empty?
  #     platform = @object.devices.order(created_at: :desc).first.platform
  #     OpenSSL::HMAC.hexdigest(
  #       'sha256', # hash function
  #       Rails.secrets.dig(:intercom, :identity_verification_secret, platform.to_sym), # secret key (keep safe!)
  #       @object.id.to_s # user's id
  #     )
  #   end
  # end

  # We need to check if a user already exists, and if so, what
  # stage of onboarding they are at. During sign-up, we want users
  # to be able to "resume" the stage of onboarding they dropped off at.
  #
  # Unfortunately, this is not a rest-like action, so we need to be a little
  # creative. Let's take advantage of the around_save hook to check
  #  - is this a new user model instance (built, attributes assigned, but not saved)?
  #  - does this user exist already?
  #  - if so, what stage of onboarding is this user at?
  #
  #  - If it is a new user model instance, we know: the Resource#build method was used to construct it
  #    - this is only called in the Controller#create method
  #  - If the user exists already:
  #    - and the user has not finished onboarding
  #      - we want to yield the found user model to resume onboarding
  #    - and the user has finished onboarding
  #      - we want to yield the passed-in user model to show correct errors
  around_save do |model|
    if model.new_record?
      existing_user = User.find_by(email: model.email)
      if existing_user.present? && !existing_user&.has_completed_onboarding?
        yield existing_user
      else
        yield model
      end
    else
      yield model
    end
  end
end
