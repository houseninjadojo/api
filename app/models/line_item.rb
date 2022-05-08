# == Schema Information
#
# Table name: line_items
#
#  id            :uuid             not null, primary key
#  amount        :string           default("0"), not null
#  description   :string
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
class LineItem < ApplicationRecord
  # callbacks

  # associations

  belongs_to :invoice

  # validations

  validates :amount,     presence: true
  validates :hubspot_id, uniqueness: true, allow_nil: true
  validates :stripe_id,  uniqueness: true, allow_nil: true

  # helpers
end
