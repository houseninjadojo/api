class Sync::User::Stripe::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? &&
    ready_to_create?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def ready_to_create?
    record.onboarding_step != OnboardingStep::CONTACT_INFO
  end
end
