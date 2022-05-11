# == Schema Information
#
# Table name: line_items
#
#  id            :uuid             not null, primary key
#  amount        :string           default("0"), not null
#  description   :string
#  name          :string
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
class LineItemResource < ApplicationResource
  self.model = LineItem
  self.type = 'line-items'

  primary_endpoint 'line-items', [:index, :show]

  belongs_to :invoice

  attribute :id, :uuid

  attribute :invoice_id, :uuid, only: [:filterable]

  attribute :amount,      :string,  except: [:writeable]
  attribute :description, :string,  except: [:writeable]
  attribute :name,        :string,  except: [:writeable]
  attribute :quantity,    :integer, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
