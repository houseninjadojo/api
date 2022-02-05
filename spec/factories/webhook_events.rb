# == Schema Information
#
# Table name: webhook_events
#
#  id               :uuid             not null, primary key
#  webhookable_type :string
#  webhookable_id   :bigint
#  service          :string           default(""), not null
#  payload          :json
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_webhook_events_on_service      (service)
#  index_webhook_events_on_webhookable  (webhookable_type,webhookable_id)
#
FactoryBot.define do
  factory :webhook_event do
    service { 'stripe' }
    payload { {} }
  end
end
