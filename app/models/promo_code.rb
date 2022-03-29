# == Schema Information
#
# Table name: promo_codes
#
#  id            :uuid             not null, primary key
#  active        :boolean          default(FALSE), not null
#  code          :string           not null
#  name          :string
#  percent_off   :string
#  stripe_id     :string
#  stripe_object :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  amount_off    :string
#  coupon_id     :string
#
# Indexes
#
#  index_promo_codes_on_code       (code) UNIQUE
#  index_promo_codes_on_coupon_id  (coupon_id)
#  index_promo_codes_on_stripe_id  (stripe_id) UNIQUE
#
class PromoCode < ApplicationRecord
  # callbacks
  before_validation :format_code

  # associations
  has_many :invoices
  has_many :subscriptions
  has_many :users

  # validations
  validates :code,      uniqueness: true, allow_nil: true
  validates :stripe_id, uniqueness: true, allow_nil: true

  # callbacks
  def format_code
    self.code = self.code.upcase if self.code.present?
  end
end
