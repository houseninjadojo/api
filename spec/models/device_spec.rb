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
require 'rails_helper'

RSpec.describe Device, type: :model do
  describe 'associations' do
    subject { build(:device) }
    it { should belong_to(:user).optional }
    it { should have_many(:push_notifications) }
  end

  describe 'validations' do
    subject { build(:device) }
    it { should validate_presence_of(:device_id) }
    # it { should validate_uniqueness_of(:device_id) }
  end
end
