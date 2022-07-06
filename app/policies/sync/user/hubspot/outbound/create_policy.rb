class Sync::User::Hubspot::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? && should_sync?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def should_sync?
    # # we want to hold on creating hubspot contacts until
    # # the customer hits the welcome step
    # record.onboarding_step == OnboardingStep::WELCOME
    enabled?
  end


  def enabled?
    ENV["HUBSPOT_OUTBOUND_DISABLED"] != "true"
  end
end
