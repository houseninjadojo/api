
class Sync::User::Stripe::Outbound::UpdatePolicy < ActionPolicy::Base
  class Changeset < TreeDiff
    # observe :email,
    observe :first_name,
            :last_name,
            :phone_number
  end

  authorize :user, optional: true
  authorize :changeset

  def can_sync?
    has_external_id? &&
    has_changed_attributes?
  end

  def has_external_id?
    record.stripe_id.present?
  end

  def has_changed_attributes?
    !changeset.blank?
  end
end
