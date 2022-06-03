module Syncable
  extend ActiveSupport::Concern

  def sync!
    # SyncResourceJob.perform_later(self)
  end

  def should_sync_externally?
    self.saved_changes?
  end

  def syncable_services
    ['hubspot']
  end

  def sync_with(service:)
    # SyncResourceJob.perform_later(self, service: service)
  end

  def sync_all!
    syncable_services.each do |service|
      sync_with(service: service)
    end
  end

  class_methods do
    def sync_from(service:, resource:)
    end
  end
end

# scenario: payment method added by user
#
# 1. api: payment_method created
# 2. api: after_create - sync payment_method to stripe job enqueued
# 3. api: gate - should_sync?
#   - true: not yet synced
# 4. api: stripe api called
#   - stripe_id persisted
# 5. stripe: payment_method created in stripe
# 6. stripe: webhook triggered
# 7. api: stripe webhook received
# 8. api: find payment_method via stripe_id
# 9. api: webhook payload mapped to payment_method attributes
# 10. api: payment_method.save called
# 11. api: after_save - sync payment_method to stripe job enqueued
# 12. api: gate - should_sync?
#    - (currently) true: updated_at, stripe_object modified
#
# = loop

# scenario: customer email updated in hubspot
#
# 1. hubspot: customer email updated
# 2. hubspot: webhook triggered
# 3. api: hubspot webhook received
# 4. api: find user via hubspot_id
# 5. api: webhook payload mapped to user attributes
# 6. api: user.save called
# 7. api: after_save
#   - sync user to hubspot job enqueued
#   - sync user to stripe job enqueued
#   - sync user to auth0 job enqueued
# 8. api: gate - should_sync?
#   - 