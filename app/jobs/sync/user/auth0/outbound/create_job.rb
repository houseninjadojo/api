class Sync::User::Auth0::Outbound::CreateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user

  # @see https://auth0.com/docs/api/management/v2#!/Users/post_users
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#create_user-instance_method
  def perform(user)
    @user = user
    return unless policy.can_sync?

    create_user!
    assign_roles!
  end

  def create_user!
    begin
      AuthZero.client.create_user(AuthZero.connection, **params)
      user.update!(
        auth_zero_user_created: true,
        onboarding_step: OnboardingStep::COMPLETED
      )
    rescue Auth0::HTTPError, Auth0::Exception => e
      Rails.logger.error(
        "Auth0 - Error Creating User `#{user.auth_id}`",
        active_job: { id: job&.job_id, class: self.class.name },
        usr: { id: user&.id, email: user&.email },
        error: e
      )
      raise e
    end
  end

  def assign_roles!
    begin
      AuthZero.client.add_user_roles(user.auth_id, role_params)
    rescue Auth0::HTTPError, Auth0::Exception => e
      Rails.logger.error(
        "Auth0 - Error Updating User Roles `#{user.auth_id}`",
        active_job: { id: job&.job_id, class: self.class.name },
        usr: { id: user&.id, email: user&.email },
        error: e
      )
      raise e
    end
  end

  def params
    AuthZero::Params.for_create_user(user)
  end

  def role_params
    if user.is_subscribed?
      AuthZero::Params.roles_for_subscribed
    else
      AuthZero::Params.roles_for_unsubscribed
    end
  end

  def policy
    Sync::User::Auth0::Outbound::CreatePolicy.new(
      user
    )
  end
end
