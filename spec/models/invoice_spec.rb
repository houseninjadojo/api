# == Schema Information
#
# Table name: invoices
#
#  id                   :uuid             not null, primary key
#  access_token         :string
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
#  index_invoices_on_access_token     (access_token) UNIQUE
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
#  fk_rails_...  (work_order_id => work_orders.id) ON DELETE => cascade
#
require 'rails_helper'

RSpec.describe Invoice, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
