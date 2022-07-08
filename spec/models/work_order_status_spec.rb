# == Schema Information
#
# Table name: work_order_statuses
#
#  id                  :uuid             not null, primary key
#  name                :string
#  slug                :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  hubspot_id          :string
#  hubspot_pipeline_id :string
#
# Indexes
#
#  index_work_order_statuses_on_hubspot_id  (hubspot_id) UNIQUE
#  index_work_order_statuses_on_slug        (slug) UNIQUE
#
require 'rails_helper'

RSpec.describe WorkOrderStatus, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
