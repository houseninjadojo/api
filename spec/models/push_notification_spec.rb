# == Schema Information
#
# Table name: push_notifications
#
#  id              :uuid             not null, primary key
#  analytics_label :string
#  body            :string
#  data            :jsonb            not null
#  delivered_at    :datetime
#  error_code      :string
#  fcm_token       :string
#  image_url       :string
#  opened_at       :datetime
#  options         :jsonb            not null
#  response        :jsonb
#  sent_at         :datetime
#  title           :string           not null
#  topic           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  device_id       :uuid             not null
#  fcm_message_id  :string
#  fcm_project_id  :string
#  priority_id     :string           default("default"), not null
#  visibility_id   :string           default("private"), not null
#
# Indexes
#
#  index_push_notifications_on_device_id       (device_id)
#  index_push_notifications_on_fcm_message_id  (fcm_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#
require 'rails_helper'

RSpec.describe PushNotification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
