class Sync::User::Auth0::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user

  # @see https://auth0.com/docs/api/management/v2#!/Users/post_users
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#create_user-instance_method
  def perform(user)
    @user = user
    return unless policy.can_sync?

    AuthZero.client.create_user(AuthZero.connection, **params)
    user.update!(auth_zero_user_created: true, onboarding_step: OnboardingStep::COMPLETED)
  end

  def params
    AuthZero::Params.for_create_user(user)
  end

  def policy
    Sync::User::Auth0::Outbound::CreatePolicy.new(
      user
    )
  end
end
