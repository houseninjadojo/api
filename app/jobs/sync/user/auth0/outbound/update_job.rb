class Sync::User::Auth0::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user, :changeset

  discard_on Auth0::HTTPError do |job, error|
    Rails.logger.error(
      "Auth0 - Error Updating User `#{user.auth_id}`",
      active_job: { id: job&.job_id },
      usr: { id: user&.id, email: user&.email },
      error: e
    )
  end

  discard_on Auth0::NotFound do |job, error|
    Rails.logger.error(
      "Auth0 - User Not Found for `#{user.auth_id}`",
      active_job: { id: job&.job_id },
      usr: { id: user&.id, email: user&.email },
      error: error
    )
  end

  # @see https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#patch_user-instance_method
  def perform(user, changeset)
    @changeset = changeset
    @user = user
    return unless policy.can_sync?

     uthZero.client.patch_user(user.auth_id, params)
    # begin
    #   AuthZero.client.patch_user(user.auth_id, params)
    # rescue Auth0::NotFound
    #   Rails.logger.error("Auth0 - User Not Found for `#{user.auth_id}`", usr: { id: user&.id, email: user&.email })
    # rescue Auth0::HTTPError, Auth0::Exception => e
    #   Rails.logger.error("Auth0 - Error Updating User `#{user.auth_id}`", usr: { id: user&.id, email: user&.email }, error: e)
    # end
  end

  def params
    AuthZero::Params.for_patch_user(user)
  end

  def policy
    Sync::User::Auth0::Outbound::UpdatePolicy.new(
      user,
      changeset: changeset
    )
  end
end
