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
class PushNotification < ApplicationRecord
  encrypts :fcm_token

  # attributes

  def deeplink_path
    data['deeplink_path']
  end

  def deeplink_path=(value)
    data['deeplink_path'] = value
  end

  def user=(value)
    self.device = value.current_device
  end

  # associations

  belongs_to :device, required: true
  belongs_to_active_hash :priority, class_name: 'PushNotification::Priority'
  belongs_to_active_hash :visibility, class_name: 'PushNotification::Visibility'

  # validations

  validates :title,   presence: true
  # validates :body,    presence: true

  # callbacks

  before_validation :ensure_defaults
  before_save :capture_token

  def ensure_defaults
    self.priority ||= Priority::DEFAULT.id
    self.visibility ||= Visibility::PRIVATE.id
    self.options ||= {}
    self.data ||= {}
  end

  def capture_token
    self.fcm_token ||= device&.fcm_token
  end

  # helpers

  def sent?
    sent_at.present?
  end

  def to_fcm_payload
    {
      token: fcm_token,
      data: data,
      notification: {
        title: title,
        body: body,
        image: image_url,
      },
      topic: topic,
      fcm_options: {
        analytics_label: analytics_label,
      }
    }
  end

  def deliver_now
    return false if sent?
    self.sent_at = Time.now
    res = FCMClient.send_notification(to_fcm_payload)
    res[:body] = JSON.parse(res[:body])&.symbolize_keys
    self.response = res
    if res[:status_code] == 200
      self.delivered_at = DateTime.parse(res[:headers]["date"])
      self.fcm_message_id = res[:body][:name].split('/').last
      self.fcm_project_id = res[:body][:name].split('/').second
    else
      self.error_code = res[:status_code]
      return false
    end
    self.save
  end

  def deliver_later
    return if sent?
    PushNotification::DeliverJob.perform_later(self)
  end
end
