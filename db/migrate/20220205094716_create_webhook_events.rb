class CreateWebhookEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :webhook_events, id: :uuid do |t|
      t.belongs_to :webhookable, polymorphic: true

      t.string :service, default: '', null: false, index: true
      t.json   :payload

      t.timestamps
    end
  end
end
