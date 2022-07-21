class AddTestMarkToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :test_account, :boolean, default: false
  end
end
