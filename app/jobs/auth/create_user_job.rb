class Auth::CreateUserJob < ApplicationJob
  sidekiq_options retry: 1
  queue_as :critical

  # @see https://auth0.com/docs/api/management/v2#!/Users/post_users
  # @see https://www.rubydoc.info/gems/auth0/Auth0/Api/V2/Users#create_user-instance_method
  def perform(user)
    return unless user.password.present?

    params = AuthZero::Params.for_create_user(user)
    AuthZero.client.create_user(AuthZero.connection, **params)
    user.update!(auth_zero_user_created: true)
  end
end
