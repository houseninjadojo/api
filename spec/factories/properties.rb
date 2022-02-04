# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  lot_size        :float
#  home_size       :float
#  garage_size     :float
#  year_built      :integer
#  estimated_value :string
#  bedrooms        :float
#  bathrooms       :float
#  pools           :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  service_area_id :uuid
#  default         :boolean
#  selected        :boolean
#
# Indexes
#
#  index_properties_on_service_area_id       (service_area_id)
#  index_properties_on_user_id               (user_id)
#  index_properties_on_user_id_and_default   (user_id,default) UNIQUE
#  index_properties_on_user_id_and_selected  (user_id,selected)
#

FactoryBot.define do
  factory :property do
    service_area
    user
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
