# == Schema Information
#
# Table name: properties
#
#  id              :uuid             not null, primary key
#  user_id         :uuid
#  lot_size        :integer
#  home_size       :integer
#  garage_size     :integer
#  home_age        :integer
#  estimated_value :string
#  bedrooms        :integer
#  bathrooms       :integer
#  pools           :integer
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
  validates :lot_size,        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :home_size,       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :garage_size,     numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :home_age,        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :estimated_value, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bedrooms,        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bathrooms,       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :pools,           numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates_associated :address

  # Return the `default` property
  # As of now, just return the first (and probably only)
  #
  # @todo add a real default type deal when we open up multiple properties
  def self.find_default_for(user:)
    user.properties.first
  end
end
