class CreatePushNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :push_notifications, id: :uuid do |t|
      t.references :device, type: :uuid, null: false, foreign_key: true

      t.string :fcm_message_id, index: { unique: true }
      t.string :fcm_project_id
      t.string :fcm_token

      t.string :priority_id, default: 'default', null: false
      t.string :visibility_id, default: 'private', null: false
      t.string :topic
      t.string :analytics_label

      t.string :title, null: false
      t.string :body
      t.string :image_url

      t.jsonb :data, null: false, default: {}
      t.jsonb :response

      t.jsonb :options, null: false, default: {}

      t.datetime :sent_at
      t.datetime :delivered_at
      t.datetime :opened_at

      t.string :error_code
      # t.string :error_message

      t.timestamps
    end
  end
end
