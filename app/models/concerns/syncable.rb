module Syncable
  extend ActiveSupport::Concern

  included do
    after_initialize :track_update_changes
  end

  def sync_thread_id(service:, action: :update, direction: :outbound)
    SyncChangeset.changeset_thread_id(record: self, service: service, action: action, direction: direction)
  end

  def sync_changeset(service:, action: :update, direction: :outbound)
    thread_id = sync_thread_id(service: service, action: action, direction: direction)
    Thread.current[thread_id]
  end

  def sync_changeset_klass(service:, action: :update, direction: :outbound)
    SyncChangeset.changeset_class(record: self, service: service, action: action, direction: direction)
  end

  # sets a thread-local change tracking object for each service on the syncable resource
  # we will use this change tracking object to detect when attributes or association attributes are modified during the request cycle.
  # this is used to determine if we should sync the resource to the service during :update actions
  def track_update_changes
    sync_services.each do |service|
      thread_id = sync_thread_id(service: service)
      klass = sync_changeset_klass(service: service)
      Thread.current[thread_id] = klass.new(self)
    end
  end

  def remove_change_tracking
    sync_services.each do |service|
      thread_id = sync_thread_id(service: service)
      Thread.current[thread_id] = nil
    end
  end

  def sync_services
    # OVERRIDE THIS
    [
      # :arrivy,
      # :auth0,
      # :hubspot,
      # :stripe,
    ]
  end

  def sync_actions
    [
      # :create,
      # :update,
      # :delete,
    ]
  end

  def sync_associations
    [
      # OVERRIDE THIS
    ]
  end

  def sync_create!
    return unless sync_actions.include?(:create)
    sync_services.each { |service| sync!(service: service, action: :create) }
  end

  def sync_update!
    return unless sync_actions.include?(:update)
    sync_services.each { |service| sync!(service: service, action: :update) }
  end

  def sync_update_associations!
    return unless sync_associations.any?
    sync_associations.each { |association| self.send(association)&.sync_update! }
  end

  def sync_delete!
    return unless sync_actions.include?(:delete)
    sync_services.each { |service| sync!(service: service, action: :delete) }
  end

  def sync_policy(service:, action:)
    "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Policy".safe_constantize
  end

  def sync_job(service:, action:)
    "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Job".safe_constantize
  end

  def should_sync_service?(service:, action:)
    return false unless sync_actions.include?(action)
    policy = sync_policy(service: service, action: action)
    case action
    when :create
      policy.new(self).can_sync?
    when :update
      changeset = sync_changeset(service: service)
      policy.new(self, changeset: changeset&.changes).can_sync?
    when :delete
      policy.new(self).can_sync?
    end
  end

  def sync!(service:, action:, perform_now: false)
    binding.pry
    return unless should_sync_service?(service: service, action: action)
    job = sync_job(service: service, action: action)
    method = perform_now ? :perform_now : :perform_later
    case action
    when :create
      job.send(method, self)
    when :update
      changeset = sync_changeset(service: service)
      job.send(method, self, changeset: changeset&.changes)
    when :delete
      job.send(method, self)
    end
  end

  def sync_now!(service:, action:)
    sync!(service: service, action: action, perform_now: true)
  end

  # modify these things
  # update EACH UPDATE POLICY
  #   - define changeset with attributes + association attributes
  #   - update policy to check changeset instead of attributes
  # update EACH UPDATE JOB - perform(self, update_changeset(service: service).changes.as_json) # "changeset"

  # REmAINING
  # 1. the above changeset adoption
  # 2. 

  def should_update_sync?
    # (
      self.saved_changes? &&                        # only sync if there are changes
      self.saved_changes.keys != ['updated_at'] &&  # do not sync if no attributes actually changed
    # ) || (

    # )
    self.previously_new_record? == false &&       # do not sync if this is a new record
    self.new_record? == false                     # do not sync if it is not persisted
  end
  alias should_sync? should_update_sync?
end
