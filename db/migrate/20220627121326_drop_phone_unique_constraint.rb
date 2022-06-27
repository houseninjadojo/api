class DropPhoneUniqueConstraint < ActiveRecord::Migration[7.0]
  def change
    remove_index :users, :phone_number
  end
end
