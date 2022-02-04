# == Schema Information
#
# Table name: service_areas
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  zipcodes     :string           default([]), not null, is an Array
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  calendar_url :string
#
# Indexes
#
#  index_service_areas_on_name      (name)
#  index_service_areas_on_zipcodes  (zipcodes) USING gin
#
FactoryBot.define do
  factory :service_area do
    name { "Austin" }
    zipcodes {
      [
        78702,
        78703,
        78704,
        78705,
        78717,
        78719,
        78721,
        78722,
        78723,
        78724,
        78725,
        78726,
        78727,
        78728,
        78729,
        78730,
        78731,
        78732,
        78733,
        78735,
        78741,
        78742,
        78744,
        78745,
        78746,
        78751,
        78752,
        78753,
        78754,
        78756,
        78757,
        78758,
        78759,
      ]
    }
    calendar_url { "https://meetings.hubspot.com/miles-zimmerman?embed=true" }
  end
end
