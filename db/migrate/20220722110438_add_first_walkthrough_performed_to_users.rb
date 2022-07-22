class AddFirstWalkthroughPerformedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_walkthrough_performed, :boolean, default: false, null: false
  end
end
