# == Schema Information
#
# Table name: promo_codes
#
#  id                 :uuid             not null, primary key
#  active             :boolean          default(FALSE), not null
#  amount_off         :string
#  code               :string           not null
#  duration           :string
#  duration_in_months :integer
#  name               :string
#  percent_off        :string
#  stripe_object      :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  coupon_id          :string
#  stripe_id          :string
#
# Indexes
#
#  index_promo_codes_on_code       (code) UNIQUE
#  index_promo_codes_on_coupon_id  (coupon_id)
#  index_promo_codes_on_stripe_id  (stripe_id) UNIQUE
#
class PromoCode < ApplicationRecord
  REFERRAL_CODE_COUPON_ID = 'referral_code'

  scope :referral_codes, -> { where(coupon_id: REFERRAL_CODE_COUPON_ID) }

  # default_scope { order(created_at: :asc) }

  # callbacks

  before_validation :generate_code, on: :create
  before_validation :format_code

  after_create_commit :sync_create!
  after_create_commit :resync_users! # sync the promo code with hubspot if its a referral

  # associations

  has_many :invoices
  has_many :subscriptions
  has_many :users

  # validations

  validates :code,
    uniqueness: true,
    allow_nil: true
  validates :stripe_id,
    uniqueness: true,
    allow_nil: true
  validates :duration,
    inclusion: {
      in: %w[once repeating forever]
    },
    allow_nil: true
  validates :duration_in_months,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    },
    allow_nil: true

  # callbacks

  def generate_code
    self.code ||= SecureRandom.hex(4)
  end

  def format_code
    self.code = self.code.upcase if self.code.present?
  end

  # helpers

  def self.find_coupon_by(months:)
    Coupon.find_by(
      system_coupon: false,
      percent_off: "100",
      duration: "repeating",
      duration_in_months: months,
    )
  end

  # sync

  include Syncable

  def sync_services
    [
      # :arrivy,
      # :auth0,
      # :hubspot,
      :stripe,
    ]
  end

  def sync_actions
    [
      :create,
      # :update,
      :delete,
    ]
  end

  def resync_users!
    self.users.each(&:sync_update!)
  end
end
