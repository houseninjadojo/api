class Sync::User::Auth0::Outbound::UpdateJob < Sync::BaseJob
  queue_as :default

  attr_accessor :user, :changeset

  discard_on Auth0::HTTPError, Auth0::Exception, Auth0::NotFound

  # @see https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#patch_user-instance_method
  def perform(user, changeset)
    @changeset = changeset
    @user = user

    unless policy.can_sync?
      Rails.logger.info(
        "Sync::User::Auth0::Outbound::UpdateJob - Skipping Sync",
        usr: { id: user.id, email: user.email },
        active_job: { id: job_id, class: self.class.name },
        changeset: changeset
      )
      return
    end

    begin
      AuthZero.client.patch_user(user.auth_id, params)
    rescue Auth0::NotFound => e
      Rails.logger.error(
        "Auth0 - User Not Found for `#{user.auth_id}`",
        active_job: { id: job&.job_id },
        usr: { id: user&.id, email: user&.email },
        error: e
      )
      raise e
    rescue Auth0::HTTPError, Auth0::Exception => e
      Rails.logger.error(
        "Auth0 - Error Updating User `#{user.auth_id}`",
        active_job: { id: job&.job_id, class: self.class.name },
        usr: { id: user&.id, email: user&.email },
        error: e
      )
      raise e
    end
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
