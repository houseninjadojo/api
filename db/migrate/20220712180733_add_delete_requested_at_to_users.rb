class AddDeleteRequestedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :delete_requested_at, :timestamp
  end
end
