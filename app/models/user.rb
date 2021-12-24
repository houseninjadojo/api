# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  first_name   :string           not null
#  last_name    :string           not null
#  email        :string           default(""), not null
#  phone_number :string           not null
#  gender       :string           default("other"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_email         (email) UNIQUE
#  index_users_on_gender        (gender)
#  index_users_on_phone_number  (phone_number) UNIQUE
#

class User < ApplicationRecord
  # Associations
  has_many :properties

  # Validations
  validates :first_name,
    presence: true
  validates :last_name,
    presence: true
  validates :email,
    presence: true
  validates :phone_number,
    presence: true,
    phone: true
  validates :gender,
    inclusion: {
      in: %w(male female other)
    }

  # Temporary password token management
  # VGS Volatile tokens expire in 1 hour
  def password=(val)
    Rails.cache.write(self.id, val, namespace: 'user:password', expires_in: 1.hour)
  end

  def password
    Rails.cache.read(self.id, namespace: 'user:password')
  end
  
  # Get the user's default property
  #
  # @return {Property}
  def default_property
    self.properties.first
  end

  # User Full Name (first_name + last_name)
  #
  # @return {string} full name
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  alias name full_name
end
