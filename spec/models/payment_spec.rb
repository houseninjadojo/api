# == Schema Information
#
# Table name: payments
#
#  id                   :uuid             not null, primary key
#  amount               :string
#  description          :string
#  paid                 :boolean          default(FALSE), not null
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
require 'rails_helper'

RSpec.describe Payment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
