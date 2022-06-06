class Sync::User::Auth0::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  attr_accessor :user, :changed_attributes

  def perform(user, changed_attributes)
    @changed_attributes = changed_attributes
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
      changed_attributes: changed_attributes
    )
  end
end
