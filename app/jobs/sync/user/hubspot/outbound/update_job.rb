class Sync::User::Hubspot::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user, :changeset

  def perform(user, changeset)
    @changeset = changeset
    @user = user
    return unless policy.can_sync?

    Hubspot::Contact.update!(user.hubspot_id, params)
  end

  def params
    {
      email:         user.email,
      firstname:     user.first_name,
      lastname:      user.last_name,
      phone:         user.phone_number,
      zip:           zip,

      onboarding_code:  user.onboarding_code,
      onboarding_link:  user.onboarding_link,
      onboarding_step:  user.onboarding_step,
      onboarding_token: user.onboarding_token,

      contact_type:  user.contact_type,
      customer_type: user.customer_type,

      # promo code used in signup, NOT the customer's referrral promo code
      'promo_code_used_': user&.subscription&.promo_code&.code,

      # customer's referral promo code
      personal_referral_code: user&.promo_code&.code,

      how_did_you_hear_about_us_: user.how_did_you_hear_about_us,
    }.compact
  end

  def policy
    Sync::User::Hubspot::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end

  def zip
    case user.contact_type
    when ContactType::SERVICE_AREA_REQUESTED
      user.requested_zipcode
    when ContactType::CUSTOMER, ContactType::LEAD
      user&.default_property&.zipcode
    end
  end
end
