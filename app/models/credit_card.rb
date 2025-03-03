# == Schema Information
#
# Table name: payment_methods
#
#  id           :uuid             not null, primary key
#  brand        :string
#  card_number  :string
#  country      :string
#  cvv          :string
#  deleted_at   :datetime
#  exp_month    :string
#  exp_year     :string
#  last_four    :string
#  stripe_token :string
#  type         :string
#  zipcode      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_payment_methods_on_stripe_token  (stripe_token) UNIQUE
#  index_payment_methods_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class CreditCard < PaymentMethod
  before_validation :normalize_year
  before_validation :normalize_card_number
  after_validation :set_derived_card_values

  validates :card_number, credit_card_number: true
  validates :exp_month,
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 12,
    }
  validates :exp_year,
    numericality: {
      greater_than_or_equal_to: 2022,
    }

  def set_derived_card_values
    detector = CreditCardValidations::Detector.new(self.card_number)
    self.brand = detector.brand.to_s
  end

  # "4242-4242-4242-4242" => "4242424242424242"
  def normalize_card_number
    self.card_number = self.card_number&.gsub(/\D/,'')
  end

  # convert from "22" => "2022"
  def normalize_year
    return unless self.exp_year.present?
    self.exp_year = self.exp_year&.to_s
    if self.exp_year.length == 2
      self.exp_year = "20#{self.exp_year}"
    end
  end

  def obfuscated_card_number
    self.card_number&.gsub(/\d(?=\d{4})/, '*')
  end

  # sync

  # def sync_create!
  #   super # lets make sure w're invoking the parent
  # end
end
