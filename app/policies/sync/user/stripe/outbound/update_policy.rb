
class Sync::User::Stripe::Outbound::UpdatePolicy < ActionPolicy::Base
  class Changeset < TreeDiff
    observe :email,
            :first_name,
            :last_name,
            :phone_number
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
    record.stripe_id.present?
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
  #     'phone_number',
  #   ]
  # end
end
