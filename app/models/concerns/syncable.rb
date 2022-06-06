module Syncable
  include ActiveSupport::Concern

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

  def sync_create!
    return unless sync_actions.include?(:create)
    sync_services.each { |service| sync!(service: service, action: :create) }
  end

  def sync_update!
    return unless sync_actions.include?(:update)
    sync_services.each { |service| sync!(service: service, action: :update) }
  end

  def sync_delete!
    return unless sync_actions.include?(:delete)
    sync_services.each { |service| sync!(service: service, action: :delete) }
  end

  def should_sync_service?(service:, action:)
    return false unless sync_actions.include?(action)
    policy = "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Policy".constantize
    case action
    when :create
      policy.new(self).can_sync?
    when :update
      policy.new(self, changed_attributes: self.changed_attributes).can_sync?
    when :delete
      policy.new(self).can_sync?
    end
  end

  def sync!(service:, action:)
    return unless should_sync_service?(service: service, action: action)
    job = "Sync::#{self.class.name}::#{service.capitalize}::Outbound::#{action.capitalize}Job".constantize
    case action
    when :create
      job.perform_later(self)
    when :update
      job.perform_later(self, self.saved_changes)
    when :delete
      job.perform_later(self)
    end
  end

  def should_sync?
    self.saved_changes? &&                        # only sync if there are changes
    self.saved_changes.keys != ['updated_at'] &&  # do not sync if no attributes actually changed
    self.previously_new_record? == false &&       # do not sync if this is a new record
    self.new_record? == false                     # do not sync if it is not persisted
  end
  alias :should_sync_outbound? :should_sync?
end
