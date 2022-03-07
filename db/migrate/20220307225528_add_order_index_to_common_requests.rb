class AddOrderIndexToCommonRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :common_requests, :order_index, :integer, null: true
  end
end
