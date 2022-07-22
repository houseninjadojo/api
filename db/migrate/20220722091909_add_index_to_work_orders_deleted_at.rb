class AddIndexToWorkOrdersDeletedAt < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :work_orders, :deleted_at, algorithm: :concurrently
  end
end
