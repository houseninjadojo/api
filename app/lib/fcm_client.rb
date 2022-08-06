class FCMClient
  def self.client
    @client ||= FCM.new(
      Rails.secrets.dig(:firebase, :cloud_messaging, :server_key),
      StringIO.new(Rails.secrets[:google].to_json),
      Rails.secrets.dig(:firebase, :project_id)
    )
  end

  def self.send_notification(payload)
    client.send_v1(payload)
  end
end
