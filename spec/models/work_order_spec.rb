# == Schema Information
#
# Table name: work_orders
#
#  id                     :uuid             not null, primary key
#  property_id            :uuid             not null
#  status                 :string
#  description            :string
#  vendor                 :string
#  scheduled_date         :string
#  scheduled_time         :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  hubspot_id             :string
#  hubspot_object         :jsonb
#  homeowner_amount       :string
#  vendor_amount          :string
#  scheduled_window_start :datetime
#  scheduled_window_end   :datetime
#
# Indexes
#
#  index_work_orders_on_hubspot_id   (hubspot_id) UNIQUE
#  index_work_orders_on_property_id  (property_id)
#
require 'rails_helper'

RSpec.describe WorkOrder, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
