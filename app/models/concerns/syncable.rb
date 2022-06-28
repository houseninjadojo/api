module Syncable
  extend ActiveSupport::Concern

  included do
    after_initialize :track_update_changes
  end

  # sets a thread-local change tracking object for each service on the syncable resource
  # we will use this change tracking object to detect when attributes or association attributes are modified during the request cycle.
  # this is used to determine if we should sync the resource to the service during :update actions
  def track_update_changes(include_associations: true)
    @changesets = {}
    sync_services.each do |service|
      @changesets[service] = SyncChangeset.initialize_changeset(record: self, service: service, action: :update)
    end
    if include_associations == true
      sync_associations.each do |association|
        [self.send(association)].flatten.each do |association_record|
          association_record&.track_update_changes(include_associations: false)
        end
      end
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

  def sync_create!(include_associations: true)
    return unless sync_actions.include?(:create)
    sync_services.each { |service| sync!(service: service, action: :create) }
    sync_create_associations! if include_associations == true
  end

  def sync_update!(include_associations: true)
    return unless sync_actions.include?(:update)
    sync_services.each { |service| sync!(service: service, action: :update) }
    sync_update_associations! if include_associations == true
  end

  def sync_create_associations!
    return unless sync_associations.any?
    sync_associations.each do |association|
      [self.send(association)].flatten.each do |association_record|
        association_record&.sync_create!(include_associations: false)
      end
    end
  end

  def sync_update_associations!
    return unless sync_associations.any?
    sync_associations.each do |association|
      [self.send(association)].flatten.each do |association_record|
        association_record&.sync_update!(include_associations: false)
      end
    end
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
      changeset = @changesets[service]
      policy.new(self, changeset: changeset.changes).can_sync?
    when :delete
      policy.new(self).can_sync?
    end
  end

  def sync!(service:, action:, perform_now: false)
    return unless should_sync_service?(service: service, action: action)
    job = sync_job(service: service, action: action)
    method = perform_now ? :perform_now : :perform_later
    case action
    when :create
      job.send(method, self)
    when :update
      # changeset = SyncChangeset.changeset(resource_klass: self.class, record: self, service: service, action: :update)
      changeset = @changesets[service]
      job.send(method, self, changeset.changes)
    when :delete
      job.send(method, self)
    end
  end

  def sync_now!(service:, action:)
    sync!(service: service, action: action, perform_now: true)
  end

  def should_sync?
    true # @TODO remove this
  end
  alias_method :should_sync, :should_sync?
end
