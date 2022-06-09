class Sync::User::Auth0::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changeset

  # @see https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#patch_user-instance_method
  def perform(user, changeset)
    @changeset = changeset
    @user = user
    return unless policy.can_sync?

    AuthZero.client.patch_user(user.auth_id, params)
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
