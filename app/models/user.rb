# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  first_name             :string           not null
#  last_name              :string           not null
#  email                  :string           default(""), not null
#  phone_number           :string           not null
#  gender                 :string           default("other"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  requested_zipcode      :string
#  auth_zero_user_created :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_email         (email) UNIQUE
#  index_users_on_gender        (gender)
#  index_users_on_phone_number  (phone_number) UNIQUE
#
class User < ApplicationRecord
  # Associations
  has_many :devices
  has_many :payment_methods
  has_many :properties

  # Validations
  validates :first_name,   presence: true
  validates :last_name,    presence: true
  validates :email,        presence: true
  validates :phone_number, presence: true, phone: true
  validates :gender,       inclusion: { in: %w(male female other) }

  # Temporary password token management
  # VGS Volatile tokens expire in 1 hour
  attr_reader :_password

  def password=(val)
    @_password = Kredis.string("#{self.id}:tmp:password_token", expires_in: 1.hour)
    @_password.value = val
  end

  def password
    @_password ||= Kredis.string("#{self.id}:tmp:password_token")
    @_password&.value
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

  # Ensure User is synced to Auth0
  after_save do |user|
    if user.auth_zero_user_created == false
      Auth::CreateUserJob.perform_later(user.id)
    else
      # Update Password Job Here
    end
  end
end
