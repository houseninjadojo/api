class Users::GenerateOnboardingLinkJob < ApplicationJob
  queue_as :default

  def perform(user)
    @user = user
    link = DeepLink.create(payload)
    link.generate!
    @user.update!(onboarding_link: link.url)
  end

  private

  def payload
    {
      linkable: @user,
      feature: "onboarding",
      stage: @user.onboarding_step,
      data: {
        user_id: @user.id,
        onboarding_code: @user.onboarding_code,
        onboarding_step: @user.onboarding_step,
        "$fallback_url" => "https://app.houseninja.co/signup?code=#{@user.onboarding_code}",
        "$deeplink_path" => "signup?code=#{@user.onboarding_code}",
        "$web_only" => true,
      },
    }
  end
end
