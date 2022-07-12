class Users::GenerateOnboardingLinkJob < ApplicationJob
  queue_as :default

  attr_accessor :user

  def perform(user)
    @user = user

    return if user.onboarding_link.present?

    deep_link.generate!
    user.update!(onboarding_link: onboarding_link)
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
