# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  bathrooms       :float
#  bedrooms        :float
#  city            :string
#  default         :boolean
#  estimated_value :string
#  garage_size     :float
#  home_size       :float
#  lot_size        :float
#  pools           :float
#  selected        :boolean
#  state           :string
#  street_address1 :string
#  street_address2 :string
#  year_built      :integer
#  zipcode         :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_area_id :uuid
#  user_id         :uuid
#
# Indexes
#
#  index_properties_on_city                  (city)
#  index_properties_on_service_area_id       (service_area_id)
#  index_properties_on_state                 (state)
#  index_properties_on_user_id               (user_id)
#  index_properties_on_user_id_and_default   (user_id,default) UNIQUE
#  index_properties_on_user_id_and_selected  (user_id,selected)
#  index_properties_on_zipcode               (zipcode)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :property do
    service_area
    user
    street_address1 { Faker::Address.street_address }
    street_address2 { }
    city { Faker::Address.city }
    zipcode { Faker::Address.zip_code }
    state { Faker::Address.state_abbr }
    lot_size { Faker::Number.between(from: 10_000, to: 1_000_000) }
    home_size { Faker::Number.between(from: 1_000, to: 10_000) }
    garage_size { Faker::Number.between(from: 0, to: 2) }
    year_built { Faker::Number.between(from: 1900, to: Time.now.year) }
    estimated_value { Faker::Number.between(from: 500_000, to: 15_000_000) }
    bedrooms { Faker::Number.between(from: 0, to: 10) }
    bathrooms { Faker::Number.between(from: 0, to: 10) }
    pools { Faker::Number.between(from: 0, to: 1) }
    default { true }
    selected { true }
  end
end
