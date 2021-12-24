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
    @current_user ||= User.find_by(id: current_token.user_id)
  end

  def authenticate_request!
    if current_token.present?
      current_token
    else
      render_unauthorized!
    end
  end

  def render_unauthorized!
    render json: {
      errors: [
        status: "401",
        title: "Not Authorized",
        details: "Not Authorized",
      ]
    }, status: :unauthorized
  end

  private

  def token_from_header
    header = request.headers["HTTP_AUTHORIZATION"]
    match = JSONWebToken::HEADER_REGEX.match(header)
    match[-1] if match.present?
  end
end
