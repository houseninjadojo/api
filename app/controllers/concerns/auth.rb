# frozen_string_literal: true

module Auth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  def current_token
    if access_token.present?
      return access_token
    else
      @token ||= JSONWebToken.verify(token: token_from_header)
    end
  end

  def current_user
    return nil unless current_token.present?
    if access_token.present?
      user = access_token_user
    else
      user = User.find_by(id: current_token.user_id)
    end
    Sentry.set_user(
      id: user.id,
      email: user.email
    )
    @current_user ||= user
  end

  def access_token
    @access_token ||= access_token_payload&.fetch(:access_token, nil)
  end

  def access_token_user
    @access_token_user ||= begin
      user_id = access_token_payload&.fetch(:user_id, nil)
      User.find_by(id: user_id)
    end
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

  def auth_header
    @auth_header ||= request.headers["HTTP_AUTHORIZATION"]
  end

  def token_from_header
    header = request.headers["HTTP_AUTHORIZATION"]
    match = JSONWebToken::HEADER_REGEX.match(header)
    if match.present?
      return match[-1]
    elsif access_token_payload.present?
      return access_token
    end
  end

  # decrypt and reveal access token, or nil
  # access token is derived from header
  def access_token_payload
    @access_token_payload ||= begin
      header = auth_header&.gsub('Bearer ', '')
      EncryptionService.safe_decrypt(header)&.with_indifferent_access
    rescue => e
      nil
    end
  end
end
