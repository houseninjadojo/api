class AddRequestedAtToWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :requested_at, :datetime, index: true
  end
end
