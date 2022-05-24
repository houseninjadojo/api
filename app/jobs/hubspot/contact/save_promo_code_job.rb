class Hubspot::Contact::SavePromoCodeJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :promo_code

  def perform(user, promo_code)
    @user = user
    @promo_code = promo_code

    return unless conditions_met?

    Hubspot::Contact.update!(user.hubspot_id, params)
  end

  private

  def conditions_met?
    [
      user.present?,
      user.hubspot_id.present?,
      promo_code.present?,
    ].all?
  end

  def params
    {
      'promo_code_used_': promo_code.code,
    }
  end
end
