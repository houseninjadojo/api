class CreateDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :devices, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: true

      t.string :apns_device_token
      t.string :fcm_token
      t.string :device_id
      t.string :name
      t.string :model
      t.string :platform
      t.string :operating_system
      t.string :os_version
      t.string :manufacturer
      t.string :is_virtual
      t.string :mem_used
      t.string :disk_free
      t.string :disk_total
      t.string :real_disk_free
      t.string :real_disk_total
      t.string :web_view_version

      t.timestamps
    end

    add_index :devices, :device_id, unique: true
  end
end
