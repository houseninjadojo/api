# == Schema Information
#
# Table name: devices
#
#  id                :uuid             not null, primary key
#  user_id           :uuid
#  apns_device_token :string
#  fcm_token         :string
#  device_id         :string
#  name              :string
#  model             :string
#  platform          :string
#  operating_system  :string
#  os_version        :string
#  manufacturer      :string
#  is_virtual        :string
#  mem_used          :string
#  disk_free         :string
#  disk_total        :string
#  real_disk_free    :string
#  real_disk_total   :string
#  web_view_version  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_devices_on_device_id  (device_id) UNIQUE
#  index_devices_on_user_id    (user_id)
#
FactoryBot.define do
  factory :device do
    apns_device_token { "dummytoken" }
    fcm_token { "dummytoken" }
    device_id { SecureRandom.uuid }
    name { Faker::Dessert.topping }
    model { Faker::Device.model_name }
    platform { Faker::Device.platform }
    operating_system { Faker::Computer.os }
    os_version { Faker::Device.build_number }
    manufacturer { Faker::Device.manufacturer }
    is_virtual { "true" }
    mem_used { "12345" }
    disk_free { "12345" }
    disk_total { "12345" }
    real_disk_free { "12345" }
    real_disk_total { "12345" }
    web_view_version { "1" }
  end
end
