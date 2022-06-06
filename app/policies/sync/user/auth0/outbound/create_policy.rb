class Sync::User::Auth0::Outbound::CreatePolicy < ApplicationPolicy
  authorize :user, optional: true

  def can_sync?
    !has_external_id? && has_password?
  end

  def has_external_id?
    record.auth_zero_user_created == true
  end

  def has_password?
    record.password.present?
  end
end
