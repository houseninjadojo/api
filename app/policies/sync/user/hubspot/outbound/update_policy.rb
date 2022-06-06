class Sync::User::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
  authorize :user, optional: true
  authorize :changed_attributes

  def can_sync?
    should_sync? &&
    has_external_id? &&
    has_changed_attributes?
  end

  def should_sync?
    record.should_sync?
  end

  def has_external_id?
    record.hubspot_id.present?
  end

  def has_changed_attributes?
    (changed_attributes.keys & attributes).any?
  end

  private

  def attributes
    [
      'contact_type',
      'email',
      'first_name',
      'last_name',
      'phone_number',
      'requested_zipcode',
      'onboarding_code',
      'onboarding_link',
      'onboarding_step',
    ]
  end
end
