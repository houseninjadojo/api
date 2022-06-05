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

class Property < ApplicationRecord
  # associations

  has_many :documents
  has_many :work_orders
  belongs_to :service_area, required: false
  belongs_to :user

  # callbacks

  after_update_commit :sync!

  # validations

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

  # sync

  def should_sync?
    self.saved_changes? &&                        # only sync if there are changes
    self.saved_changes.keys != ['updated_at'] &&  # do not sync if no attributes actually changed
    self.previously_new_record? == false &&       # do not sync if this is a new record
    self.new_record? == false                     # do not sync if it is not persisted
  end

  def sync_jobs
    [
      Sync::Property::Arrivy::OutboundJob,
      Sync::Property::Hubspot::OutboundJob,
      Sync::Property::Stripe::OutboundJob,
    ]
  end

  def sync!
    return unless should_sync?
    sync_jobs.each do |job|
      job.perform_later(self, self.saved_changes)
    end
  end
end
