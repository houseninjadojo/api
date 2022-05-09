# == Schema Information
#
# Table name: line_items
#
#  id            :uuid             not null, primary key
#  amount        :string           default("0"), not null
#  description   :string
#  name          :string
#  price         :string
#  quantity      :integer
#  stripe_object :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  hubspot_id    :string
#  invoice_id    :uuid
#  stripe_id     :string
#
# Indexes
#
#  index_line_items_on_hubspot_id  (hubspot_id)
#  index_line_items_on_invoice_id  (invoice_id)
#  index_line_items_on_stripe_id   (stripe_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#
require 'rails_helper'

RSpec.describe LineItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
