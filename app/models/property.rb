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
#
# Indexes
#
#  index_properties_on_user_id  (user_id)
#

class Property < ApplicationRecord
  has_one :address, as: :addressible
  belongs_to :user

  validates :user_id,         presence: true
  validates :lot_size,        numericality: { greater_than_or_equal_to: 0 }
  validates :home_size,       numericality: { greater_than_or_equal_to: 0 }
  validates :garage_size,     numericality: { greater_than_or_equal_to: 0 }
  validates :home_age,        numericality: { greater_than_or_equal_to: 0 }
  validates :estimated_value, numericality: { greater_than_or_equal_to: 0 }
  validates :bedrooms,        numericality: { greater_than_or_equal_to: 0 }
  validates :bathrooms,       numericality: { greater_than_or_equal_to: 0 }
  validates :pools,           numericality: { greater_than_or_equal_to: 0 }
  validates_associated :address

  # Return the `default` property
  # As of now, just return the first (and probably only)
  #
  # @todo add a real default type deal when we open up multiple properties
  def self.find_default_for(user:)
    user.properties.first
  end

  # Get the current home age
  def home_age
    Time.now.year - self.year_built
  end
end
