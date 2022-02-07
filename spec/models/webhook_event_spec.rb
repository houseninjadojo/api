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
#  processed_at     :datetime
#
# Indexes
#
#  index_webhook_events_on_service      (service)
#  index_webhook_events_on_webhookable  (webhookable_type,webhookable_id)
#
require 'rails_helper'

RSpec.describe WebhookEvent, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
