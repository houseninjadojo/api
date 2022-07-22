class AddDeletedAtToWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :deleted_at, :datetime
  end
end
