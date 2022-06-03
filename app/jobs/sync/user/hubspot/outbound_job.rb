class Sync::User::Hubspot::OutboundJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changed_attributes

  def perform(user, changed_attributes)
    @changed_attributes = changed_attributes
    @user = user
    return unless policy.can_sync?

    Hubspot::Contact.update!(user.hubspot_id, params)
  end

  def params
    {
      contact_type: user.contact_type,
      email:        user.email,
      firstname:    user.first_name,
      lastname:     user.last_name,
      phone:        user.phone_number,
      zip:          user.requested_zipcode,

      onboarding_code: user.onboarding_code,
      onboarding_link: user.onboarding_link,
      onboarding_step: user.onboarding_step,
    }
  end

  def policy
    Sync::User::Hubspot::OutboundPolicy.new(
      user: user,
      changed_attributes: changed_attributes
    )
  end
end
