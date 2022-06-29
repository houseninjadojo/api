class AddArrivyIdToWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :arrivy_id, :string
  end
end
