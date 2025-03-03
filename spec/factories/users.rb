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

FactoryBot.define do
  factory :user do
    arrivy_id { Faker::Number.number(digits: 10).to_s }
    contact_type { ContactType::CUSTOMER }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    gender { ['male', 'female', 'other'].sample }
    stripe_id { Faker::Crypto.md5 }
    hubspot_id { Faker::Crypto.md5 }
    hubspot_contact_object { {} }
    onboarding_step { OnboardingStep::ALL.sample }
    onboarding_code { nil }

    trait :with_payment_method do
      after(:create) do |user|
        create(:payment_method, :with_stripe_token, user: user)
      end
    end
  end
end
