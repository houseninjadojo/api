class ReAddUsersPhoneNumberIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :users, :phone_number, unique: false, algorithm: :concurrently
  end
end
