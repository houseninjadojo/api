class AddOrderIndexIndexToCommonRequests < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :common_requests, :order_index, unique: true, algorithm: :concurrently
  end
end
