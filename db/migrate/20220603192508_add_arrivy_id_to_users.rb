class AddArrivyIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :arrivy_id, :string
  end
end
