class Users::GenerateReferralPromoCodeJob < ApplicationJob
  queue_as :default

  def perform(user)
    return if user.promo_code.present?
    promo_code = PromoCode.create!
    user.update!(promo_code: promo_code)
  end
end
