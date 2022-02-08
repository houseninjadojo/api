require "#{Rails.root}/lib/core_ext/rails/action_controller/exceptions"

class ApplicationController < ActionController::API
  include ActionPolicy::Controller
  include Auth
  include Graphiti::Rails::Responders

  authorize :user, through: :current_user

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

  def show_detailed_exceptions?
    # ['development', 'sandbox'].include?(Rails.env)
    false
  end
end
