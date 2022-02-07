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
class Invoice < ApplicationRecord
  # callbacks

  # associations
  has_one    :payment
  belongs_to :promo_code,   required: false
  belongs_to :subscription, required: false
  belongs_to :user,         required: false

  # validations
  validates :stripe_id, uniqueness: true, allow_nil: true
end
