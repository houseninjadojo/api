class Auth::CreateUserJob < ApplicationJob
  queue_as :critical

  # https://auth0.com/docs/api/management/v2#!/Users/post_users
  def perform(user_id)
    user = User.find(user_id)
    options = options_for_user(user)

    auth_client.create_user(auth_connection, options)
  end

  private

  def options_for_user(user)
    {
      user_id: user.id,
      email: user.email,
      email_verified: false,
      # phone_number: user.phone_number,
      # phone_verified: false,
      blocked: false,å
      name: user.name,
      # connection: connection,
      password: user.password,
      verify_email: true,
    }
  end

  def auth_client
    options = Rails.application.credentials.auth.slice(
      :client_id,
      :client_secret,
      :domain,
    ).merge({
      api_version: 2,
      timeout: 10,
    })
    @client ||= Auth0Client.new(**options)
  end

  def auth_connection
    Rails.application.credentials.auth[:connection]
  end
end
