class Sync::User::Hubspot::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    if !Rails.env.test?
      Rails.logger.info("sync policy action=create user=#{record.id}", {
        policy: {
          resource: "user",
          service: "hubspot",
          direction: "outbound",
          action: "create",
          result: can_sync_result,
        },
        resource: {
          id: record&.id,
          type: "user",
        },
        factors: {
          has_external_id: has_external_id?,
          enabled: enabled?,
        },
      })
    end
    can_sync_result
  end

  def can_sync_result
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
