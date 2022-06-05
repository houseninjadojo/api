class AddIndexOnUserArrivyId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :users, :arrivy_id, unique: true, algorithm: :concurrently
  end
end
