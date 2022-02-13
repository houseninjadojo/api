# == Schema Information
#
# Table name: invoices
#
#  id              :uuid             not null, primary key
#  promo_code_id   :uuid
#  subscription_id :uuid
#  user_id         :uuid
#  description     :string
#  status          :string
#  total           :string
#  period_start    :datetime
#  period_end      :datetime
#  stripe_id       :string
#  stripe_object   :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#
class InvoiceResource < ApplicationResource
  self.model = Invoice
  self.type = :invoices

  primary_endpoint 'invoices', [:index, :show]

  has_one    :document
  has_one    :payment
  belongs_to :promo_code
  belongs_to :subscription
  belongs_to :user

  attribute :id, :uuid

  attribute :payment_id,      :uuid, only: [:filterable]
  attribute :promo_code,      :uuid, only: [:filterable]
  attribute :subscription_id, :uuid, only: [:filterable]
  attribute :user_id,         :uuid, only: [:filterable]

  attribute :status,      :string, except: [:writeable]
  attribute :description, :string, except: [:writeable]
  attribute :total,       :string, except: [:writeable]

  attribute :period_start, :datetime, except: [:writeable]
  attribute :period_end  , :datetime, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
