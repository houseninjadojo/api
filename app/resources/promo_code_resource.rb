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
class PromoCodeResource < ApplicationResource
  self.model = PromoCode
  self.type = 'promo-codes'

  primary_endpoint 'promo-codes', [:index, :show]

  has_many :invoices
  has_many :subscriptions
  has_many :users

  attribute :id, :uuid

  attribute :code, :string, except: [:writeable]

  attribute :name,        :string, except: [:writeable]
  attribute :amount_off,  :string, except: [:writeable]
  attribute :percent_off, :string, except: [:writeable]

  attribute :active, :boolean, except: [:writeable]

  attribute :created_at, :datetime, except: [:writeable]
  attribute :updated_at, :datetime, except: [:writeable]
end
