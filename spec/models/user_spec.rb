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

require 'rails_helper'

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
