class Sync::User::Hubspot::Outbound::CreateJob < ApplicationJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user
    return unless policy.can_sync?

    contact = Hubspot::Contact.create_or_update(user.email, params)
    user.update!(
      hubspot_id:             contact.id,
      hubspot_contact_object: contact
    )
  end

  def params
    {
      contact_type:    user.contact_type,
      house_ninja_id:  user.id,
      email:           user.email,
      firstname:       user.first_name,
      lastname:        user.last_name,
      phone:           user.phone_number,

      onboarding_code: user.onboarding_code,
      onboarding_link: user.onboarding_link,
      onboarding_step: user.onboarding_step,

      how_did_you_hear_about_us_: user.how_did_you_hear_about_us,
    }
  end

  def policy
    Sync::User::Hubspot::Outbound::CreatePolicy.new(
      user
    )
  end
end
