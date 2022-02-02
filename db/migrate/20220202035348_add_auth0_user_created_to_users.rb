class AddAuth0UserCreatedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :auth_zero_user_created, :boolean, default: false, null: true
  end
end
