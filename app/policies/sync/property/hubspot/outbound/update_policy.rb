class Sync::Property::Hubspot::Outbound::UpdatePolicy < ApplicationPolicy
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
    record.user&.hubspot_id.present?
  end

  def has_changed_attributes?
    (changed_attributes.keys & attributes).any?
  end

  private

  def attributes
    [
      'street_address1',
      'street_address2',
      'city',
      'state',
      'zipcode',
    ]
  end
end
