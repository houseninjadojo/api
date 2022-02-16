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
#  index_promo_codes_on_coupon_id  (coupon_id) UNIQUE
#  index_promo_codes_on_stripe_id  (stripe_id) UNIQUE
#
require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
