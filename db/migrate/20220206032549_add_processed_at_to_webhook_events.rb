class AddProcessedAtToWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :webhook_events, :processed_at, :timestamp
  end
end
