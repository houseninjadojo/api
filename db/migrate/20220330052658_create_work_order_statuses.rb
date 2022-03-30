class CreateWorkOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :work_order_statuses, id: :uuid do |t|
      t.string :slug, null: false
      t.string :name
      t.string :hubspot_id
      t.timestamps
    end

    add_index :work_order_statuses, :slug,       unique: true
    add_index :work_order_statuses, :hubspot_id, unique: true
  end
end
