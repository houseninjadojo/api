class AddIndexToWorkOrderHubspotId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :work_orders, :hubspot_id, unique: true, algorithm: :concurrently
  end
end
