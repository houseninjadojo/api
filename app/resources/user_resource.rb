# == Schema Information
#
# Table name: users
#
#  id                                        :uuid             not null, primary key
#  auth_zero_user_created                    :boolean          default(FALSE)
#  contact_type                              :string           default("Customer")
#  delete_requested_at                       :datetime
#  deleted_at                                :datetime
#  email(Email Address)                      :string           default(""), not null
#  first_name(First Name)                    :string           not null
#  first_walkthrough_performed               :boolean          default(FALSE), not null
#  gender(Gender)                            :string           default("other"), not null
#  how_did_you_hear_about_us                 :string
#  hubspot_contact_object                    :jsonb
#  last_name(Last Name)                      :string           not null
#  onboarding_code                           :string
#  onboarding_link                           :string
#  onboarding_step                           :string
#  phone_number(Phone Number (+15555555555)) :string           not null
#  requested_zipcode                         :string
#  test_account                              :boolean          default(FALSE)
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  arrivy_id                                 :string
#  hubspot_id                                :string
#  intercom_id                               :string
#  promo_code_id                             :uuid
#  stripe_id                                 :string
#
# Indexes
#
#  index_users_on_arrivy_id        (arrivy_id) UNIQUE
#  index_users_on_email            (email) UNIQUE
#  index_users_on_gender           (gender)
#  index_users_on_hubspot_id       (hubspot_id) UNIQUE
#  index_users_on_intercom_id      (intercom_id) UNIQUE
#  index_users_on_onboarding_code  (onboarding_code) UNIQUE
#  index_users_on_phone_number     (phone_number)
#  index_users_on_promo_code_id    (promo_code_id)
#  index_users_on_stripe_id        (stripe_id) UNIQUE
#

class UserResource < ApplicationResource
  self.model = User
  self.type = :users

  primary_endpoint 'users', [:index, :show, :create, :update, :destroy]

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

  attribute :requested_zipcode,         :string, readable: false
  attribute :how_did_you_hear_about_us, :string, readable: false
  attribute :should_book_walkthrough,   :boolean, except: [:writeable] do
    # !@object.first_walkthrough_performed
    false
  end

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  attribute :intercom_hash, :string, except: [:writeable]

  attribute :contact_type, :string, except: [:writeable]

  attribute :onboarding_step, :string, except: [:writeable]
  attribute :onboarding_code, :string, except: [:writeable]

  def base_scope
    User.unscoped
  end
end
