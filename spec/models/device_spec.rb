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
require 'rails_helper'

RSpec.describe Device, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
