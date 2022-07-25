class AddDeletedAtToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deleted_at, :datetime, index: { algorithm: :concurrently }
  end
end
