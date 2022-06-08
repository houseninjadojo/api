class SyncChangeset < ActiveSupport::CurrentAttributes
  attribute :changesets

  reset { @changesets = {} }

  def initialize
    super
    @changesets = {}
  end

  def changesets=(val)
    @changesets # no-op
  end

  def changeset(record:, service:, action:, direction: :outbound)
    id = changeset_thread_id(record: record, service: service, action: action, direction: direction)
    @changesets[id]
  end

  def initialize_changeset(record:, service:, action:, direction: :outbound)
    klass = changeset_class(record: record, service: service, action: action, direction: direction)
    id = changeset_thread_id(record: record, service: service, action: action, direction: direction)
    return if klass.nil?
    @changesets ||= {}
    @changesets[id] = klass.new(record)
  end

  def changeset_class(record:, service:, action:, direction: :outbound)
    [
      "Sync",
      record.class.name,
      service.capitalize,
      direction.capitalize,
      "#{action.capitalize}Policy",
      "Changeset",
    ].join("::").safe_constantize
  end

  def changeset_thread_id(record:, service:, action:, direction: :outbound)
    [
      "changeset",
      record.class.name.downcase,
      service.downcase.to_s,
      direction.downcase.to_s,
      action.downcase.to_s,
      record.id,
    ].join(":")
  end
end
