# == Schema Information
#
# Table name: work_order_statuses
#
#  id         :uuid             not null, primary key
#  slug       :string           not null
#  name       :string
#  hubspot_id :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
