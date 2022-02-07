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
#
# Indexes
#
#  index_promo_codes_on_code       (code) UNIQUE
#  index_promo_codes_on_stripe_id  (stripe_id) UNIQUE
#
class PromoCode < ApplicationRecord
  # callbacks

  # associations
  has_many :invoices
  has_many :subscriptions
  has_many :users

  # validations
  validates :stripe_id, uniqueness: true, allow_nil: true
end
