# == Schema Information
#
# Table name: service_areas
#
#  id           :uuid             not null, primary key
#  calendar_url :string
#  name         :string           not null
#  zipcodes     :string           default([]), not null, is an Array
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_service_areas_on_name      (name)
#  index_service_areas_on_zipcodes  (zipcodes) USING gin
#
class ServiceAreaResource < ApplicationResource
  self.model = ServiceArea
  self.type = 'service-areas'

  primary_endpoint 'service-areas', [:index, :show]

  has_many :properties

  attribute :id, :uuid

  attribute :name,         :string, except: [:writeable]
  attribute :zipcodes,     :array,  except: [:writeable]
  attribute :calendar_url, :string, except: [:writeable, :sortable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
