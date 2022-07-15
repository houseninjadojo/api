class Users::GenerateOnboardingLinkJob < ApplicationJob
  queue_as :default

  unique :until_expired, runtime_lock_ttl: 1.minute, on_conflict: :log

  attr_accessor :user

  def perform(user)
    @user = user

    return if user.onboarding_link.present?

    deep_link.generate!
    user.update!(onboarding_link: onboarding_link)

    # this does not seem to work every time
    # user.sync_update!
    Sync::User::Hubspot::Outbound::UpdateJob.set(wait: 1.minute).perform_later(user)
  end

  private

  delegate :onboarding_code, :onboarding_step, to: :@user

  def payload
    {
      canonical_url: canonical_url,
      deeplink_path: deeplink_path,
      linkable: user,
      feature: "onboarding",
      stage: onboarding_step,
      path: canonical_url,
      data: {
        user_id: user_id,
        onboarding_code: onboarding_code,
        onboarding_step: onboarding_step,
        "$web_only" => false,
      },
    }
  end

  def user_id
    user&.id
  end

  def onboarding_link
    deep_link.url
  end

  def deeplink_path
    "signup?code=#{onboarding_code}"
  end

  def canonical_url
    "https://#{Rails.settings.domains[:app]}/signup?code=#{onboarding_code}"
  end

  def deep_link
    @deep_link ||= DeepLink.create(payload)
  end
end
