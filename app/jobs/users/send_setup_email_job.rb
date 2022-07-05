class Users::SendSetupEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.needs_setup?

    user.deep_links.find_by(purpose: "onboarding").destroy
    user.update!(
      onboarding_link: nil,
      onboarding_code: SecureRandom.hex(12),
    )
    Users::GenerateOnboardingLinkJob.perform_now(user)
    UserMailer.account_setup(
      email: user.email,
      url: user.onboarding_link,
    )
  end
end
