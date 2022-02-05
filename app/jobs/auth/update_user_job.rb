class Auth::UpdateUserJob < ApplicationJob
  queue_as :default

  # @see https://auth0.com/docs/api/management/v2#!/Users/patch_users_by_id
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#patch_user-instance_method
  def perform(user)
    params = AuthZero::Params.for_patch_user(user)
    AuthZero.client.patch_user(user.auth_id, params)
  end
end
