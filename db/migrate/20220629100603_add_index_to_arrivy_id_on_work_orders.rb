class AddIndexToArrivyIdOnWorkOrders < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :work_orders, :arrivy_id, unique: true, algorithm: :concurrently
  end
end
