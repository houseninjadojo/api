# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  description          :string
#  finalized_at         :datetime
#  payment_attempted_at :datetime
#  period_end           :datetime
#  period_start         :datetime
#  status               :string
#  stripe_object        :jsonb
#  total                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  promo_code_id        :uuid
#  stripe_id            :string
#  subscription_id      :uuid
#  user_id              :uuid
#  work_order_id        :uuid
#
# Indexes
#
#  index_invoices_on_promo_code_id    (promo_code_id)
#  index_invoices_on_status           (status)
#  index_invoices_on_stripe_id        (stripe_id) UNIQUE
#  index_invoices_on_subscription_id  (subscription_id)
#  index_invoices_on_user_id          (user_id)
#  index_invoices_on_work_order_id    (work_order_id)
#
# Foreign Keys
#
#  fk_rails_...  (promo_code_id => promo_codes.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#  fk_rails_...  (user_id => users.id)
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
  belongs_to :work_order

  attribute :id, :uuid

  attribute :payment_id,      :uuid, only: [:filterable]
  attribute :promo_code,      :uuid, only: [:filterable]
  attribute :subscription_id, :uuid, only: [:filterable]
  attribute :user_id,         :uuid, only: [:filterable]
  attribute :work_order_id,   :uuid, only: [:filterable]

  attribute :status,      :string, except: [:writeable]
  attribute :description, :string, except: [:writeable]
  attribute :total,       :string, except: [:writeable]

  attribute :period_start, :datetime, except: [:writeable]
  attribute :period_end  , :datetime, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
