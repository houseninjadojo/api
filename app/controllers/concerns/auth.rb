# frozen_string_literal: true

module Auth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  def current_token
    @token ||= JSONWebToken.verify(token: token_from_header)
  end

  def current_user
    return nil unless current_token.present?
    user = User.find_by(id: current_token.user_id)
    Sentry.set_user(email: user.email)
    @current_user ||= user
  end

  def authenticate_request!
    return true if Rails.env.test?

    if current_token.present?
      current_token
    else
      raise ActionController::Unauthorized
    end
  end

  private

  def token_from_header
    header = request.headers["HTTP_AUTHORIZATION"]
    match = JSONWebToken::HEADER_REGEX.match(header)
    match[-1] if match.present?
  end
end
