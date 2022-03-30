class AddHubspotColumnsToWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :hubspot_id, :string
    add_column :work_orders, :hubspot_object, :jsonb
  end
end
