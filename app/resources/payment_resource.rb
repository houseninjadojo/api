# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :string
#  description          :string
#  originator           :string
#  paid                 :boolean          default(FALSE), not null
#  purpose              :string
#  refunded             :boolean          default(FALSE), not null
#  statement_descriptor :string
#  status               :string
#  stripe_object        :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  invoice_id           :uuid
#  payment_method_id    :uuid
#  stripe_id            :string
#  user_id              :uuid
#
# Indexes
#
#  index_payments_on_invoice_id         (invoice_id)
#  index_payments_on_payment_method_id  (payment_method_id)
#  index_payments_on_status             (status)
#  index_payments_on_stripe_id          (stripe_id) UNIQUE
#  index_payments_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (payment_method_id => payment_methods.id)
#  fk_rails_...  (user_id => users.id)
#
class PaymentResource < ApplicationResource
  self.model = Payment
  self.type = :payments

  primary_endpoint 'payments', [:index, :show, :create]

  belongs_to :invoice
  belongs_to :payment_method
  belongs_to :user

  attribute :id, :uuid

  attribute :invoice_id,        :uuid, only: [:filterable]
  attribute :payment_method_id, :uuid, only: [:filterable]
  attribute :user_id,           :uuid, only: [:filterable]

  attribute :status, :string, except: [:writeable]

  attribute :amount,               :string, except: [:writeable]
  attribute :description,          :string, except: [:writeable]
  attribute :originator,           :string
  attribute :purpose,              :string
  attribute :statement_descriptor, :string, except: [:writeable]

  attribute :refunded, :boolean, except: [:writeable]
  attribute :paid,     :boolean, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
