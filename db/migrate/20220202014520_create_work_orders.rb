class CreateWorkOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :work_orders, id: :uuid do |t|
      t.references :property, type: :uuid, foreign_key: true, null: false

      t.string :status
      t.string :description
      t.string :vendor
      t.string :scheduled_date
      t.string :scheduled_time

      t.timestamps
    end
  end
end
