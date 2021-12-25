class ApplicationController < ActionController::API
  include Graphiti::Rails
  include Auth

  def context
    {
      current_user: current_user,
      current_token: current_token,
    }
  end

  # When #show action does not find record, return 404
  register_exception Graphiti::Errors::RecordNotFound, status: 404

  rescue_from Exception do |e|
    handle_exception(e)
  end

  def respond_with(payload)
    render jsonapi: payload
  end
end
