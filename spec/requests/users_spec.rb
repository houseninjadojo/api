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
#  stripe_id              :string
#  hubspot_id             :string
#  hubspot_contact_object :jsonb
#  promo_code_id          :uuid
#  contact_type           :string           default("Customer")
#  onboarding_step        :string
#  onboarding_code        :string
#  onboarding_link        :string
#
# Indexes
#
#  index_users_on_email               (email) UNIQUE
#  index_users_on_gender              (gender)
#  index_users_on_hubspot_id          (hubspot_id) UNIQUE
#  index_users_on_onboarding_code     (onboarding_code) UNIQUE
#  index_users_on_phone_number        (phone_number) UNIQUE
#  index_users_on_promo_code_id       (promo_code_id)
#  index_users_on_stripe_id           (stripe_id) UNIQUE
#
require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    pending "add some examples (or delete) #{__FILE__}"
  end
end
