class AddIntercomIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :intercom_id, :string
  end
end
