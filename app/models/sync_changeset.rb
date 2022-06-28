class SyncChangeset < ActiveSupport::CurrentAttributes
  attribute :changesets

  reset { self.changesets = {} }

  def initialize
    super
    self.changesets = {}
  end

  def changeset(record:, service:, action:, direction: :outbound, resource_klass: nil)
    default_id = changeset_thread_id(
      resource_klass: resource_klass.presence || record.class,
      record: nil,
      service: service,
      action: action,
      direction: direction
    )
    record_id = changeset_thread_id(
      resource_klass: resource_klass.presence || record.class,
      record: record,
      service: service,
      action: action,
      direction: direction
    )
    self.changesets[record_id].presence || self.changesets[default_id]
  end

  def initialize_changeset(record:, service:, action:, direction: :outbound)
    klass = changeset_klass(resource_klass: record.class, record: record, service: service, action: action, direction: direction)
    id = changeset_thread_id(resource_klass: record.class, record: record, service: service, action: action, direction: direction)
    return if klass.nil?
    if self.changesets.present? && self.changesets[id].present?
      return self.changesets[id]
    else
      self.changesets ||= {}
    end
    self.changesets[id] = klass.new(record)
  end

  def changeset_klass(resource_klass: nil, record:, service:, action:, direction: :outbound)
    [
      "Sync",
      resource_klass&.name.presence || record.class.name,
      service.capitalize,
      direction.capitalize,
      "#{action.capitalize}Policy",
      "Changeset",
    ].join("::").safe_constantize
  end

  def changeset_thread_id(resource_klass: nil, record:, service:, action:, direction: :outbound)
    [
      "changeset",
      resource_klass.name.downcase,
      service.downcase.to_s,
      direction.downcase.to_s,
      action.downcase.to_s,
      record&.id.presence || "default_id",
    ].join(":")
  end
end
