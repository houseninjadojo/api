class Sync::User::Auth0::Outbound::UpdatePolicy < ApplicationPolicy
  class Changeset < TreeDiff
    observe :email,
            :first_name,
            :last_name
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    should_sync? &&
    has_external_id? &&
    has_changed_attributes?
  end

  def should_sync?
    record.should_sync?
  end

  def has_external_id?
    record.auth_zero_user_created == true &&
    record.auth_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end

  # private

  # def attributes
  #   [
  #     'first_name',
  #     'last_name',
  #     'email',
  #   ]
  # end
end
