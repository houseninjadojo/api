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
#  street_address1 :string
#  street_address2 :string
#  city            :string
#  zipcode         :string
#  state           :string
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

class Property < ApplicationRecord
  has_many :work_orders
  belongs_to :service_area
  belongs_to :user

  # validates :lot_size,        numericality: { greater_than_or_equal_to: 0 }
  # validates :home_size,       numericality: { greater_than_or_equal_to: 0 }
  # validates :garage_size,     numericality: { greater_than_or_equal_to: 0 }
  # validates :year_built,      numericality: { greater_than_or_equal_to: 0 }
  # validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }
  # validates :bedrooms,        numericality: { greater_than_or_equal_to: 0 }
  # validates :bathrooms,       numericality: { greater_than_or_equal_to: 0 }
  # validates :pools,           numericality: { greater_than_or_equal_to: 0 }

  validates :default, uniqueness: { scope: [:user_id] }

  # Return the `default` property
  # As of now, just return the first (and probably only)
  #
  # @todo add a real default type deal when we open up multiple properties
  def self.find_default_for(user:)
    user.properties.first
  end

  # Get the current home age
  def home_age
    if self.year_built.present?
      Time.now.year - self.year_built
    else
      nil
    end
  end

  def update_from_service(service, payload)
    # if sync_flag.marked?
    #   return # we already updated
    # else
    #   mark_sync_flag!
    # end

    # User.transaction do
    #   payload.each do |k, v|
    #     update_attribute(k, v)
    #   end
    # end

    # case service
    # when "hubspot"
    #   update_auth_user
    #   update_stripe_customer
    # when "stripe"
    #   update_auth_user
    #   update_hubspot_contact
    # when "auth0"
    #   update_stripe_customer
    #   update_hubspot_contact
    # end
  end
end
