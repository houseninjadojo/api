# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  first_name        :string           not null
#  last_name         :string           not null
#  email             :string           default(""), not null
#  phone_number      :string           not null
#  gender            :string           default("other"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  requested_zipcode :string
#
# Indexes
#
#  index_users_on_email         (email) UNIQUE
#  index_users_on_gender        (gender)
#  index_users_on_phone_number  (phone_number) UNIQUE
#

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.cell_phone_in_e164 }
    gender { ['male', 'female', 'other'].sample }
  end
end
