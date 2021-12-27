require "#{Rails.root}/lib/core_ext/rails/action_controller/exceptions"

class ApplicationController < ActionController::API
  include Auth
  include Graphiti::Rails::Responders

  def context
    {
      current_user: current_user,
      current_token: current_token,
    }
  end

  register_exception ActionController::Unauthorized,
    status: 401,
    title: I18n.t('exceptions.actioncontroller.unauthorized.title'),
    message: -> (e) { I18n.t('exceptions.actioncontroller.unauthorized.detail') }
  # register_exception Graphiti::Errors::RecordNotFound,
  #   status: 404

  # rescue_from Exception do |e|
  #   handle_exception(e, show_raw_error: show_detailed_exceptions?)
  # end

  # def respond_with(payload)
  #   render jsonapi: payload
  # end

  def show_detailed_exceptions?
    # ['development', 'sandbox'].include?(Rails.env)
    false
  end
end
