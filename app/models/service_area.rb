# == Schema Information
#
# Table name: service_areas
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  zipcodes   :string           default([]), not null, is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_service_areas_on_name      (name)
#  index_service_areas_on_zipcodes  (zipcodes) USING gin
#
class ServiceArea < ApplicationRecord
  has_many :properties
end
