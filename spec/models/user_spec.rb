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

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "syncable" do
    it "should be syncable" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        user = create(:user, onboarding_step: OnboardingStep::WELCOME, hubspot_id: nil)
      }.to have_enqueued_job(Sync::User::Hubspot::Outbound::CreateJob)
    end
  end
end
