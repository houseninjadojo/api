class ApplicationController < ActionController::API
  include Auth

  def context
    {
      current_user: current_user,
      current_token: current_token,
    }
  end
end
