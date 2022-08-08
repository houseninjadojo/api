# == Schema Information
#
# Table name: devices
#
#  id                :uuid             not null, primary key
#  apns_device_token :string
#  disk_free         :string
#  disk_total        :string
#  fcm_token         :string
#  is_virtual        :string
#  manufacturer      :string
#  mem_used          :string
#  model             :string
#  name              :string
#  operating_system  :string
#  os_version        :string
#  platform          :string
#  real_disk_free    :string
#  real_disk_total   :string
#  web_view_version  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  device_id         :string
#  user_id           :uuid
#
# Indexes
#
#  index_devices_on_device_id  (device_id) UNIQUE
#  index_devices_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Device < ApplicationRecord
  encrypts :device_id, deterministic: true, downcase: true
  encrypts :apns_device_token
  encrypts :fcm_token

  # associations

  belongs_to :user, required: false
  has_many :push_notifications

  # scopes

  scope :with_token, -> { where.not(fcm_token: nil) }
  default_scope { order(created_at: :asc) }

  # validations

  validates :device_id, presence: true, uniqueness: true
end
