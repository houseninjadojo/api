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
class DeviceResource < ApplicationResource
  self.model = Device
  self.type = :devices

  primary_endpoint 'devices', [:index, :show, :create, :update]

  belongs_to :user

  attribute :user_id, :uuid, only: [:filterable]

  attribute :id,                :uuid
  attribute :apns_device_token, :string, except: [:sortable, :readable]
  attribute :fcm_token,         :string, except: [:sortable, :readable]
  attribute :device_id,         :string #, except: []
  attribute :name,              :string, except: [:sortable]
  attribute :model,             :string, except: [:sortable]
  attribute :platform,          :string, except: [:sortable]
  attribute :operating_system,  :string, except: [:sortable]
  attribute :os_version,        :string, except: [:sortable]
  attribute :manufacturer,      :string, except: [:sortable]
  attribute :is_virtual,        :string, except: [:sortable]
  attribute :mem_used,          :string, except: [:sortable]
  attribute :disk_free,         :string, except: [:sortable]
  attribute :disk_total,        :string, except: [:sortable]
  attribute :real_disk_free,    :string, except: [:sortable]
  attribute :real_disk_total,   :string, except: [:sortable]
  attribute :web_view_version,  :string, except: [:sortable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]

  def base_scope
    Device.unscoped
  end
end
