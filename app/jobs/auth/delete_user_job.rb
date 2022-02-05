class Auth::DeleteUserJob < ApplicationJob
  queue_as :default

  def perform(user_auth_id)
    AuthZero.client.delete_user(user_auth_id)
  end
end
