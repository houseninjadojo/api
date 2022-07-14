class AddIndexToWeekHomeCareTips < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :home_care_tips, :week, algorithm: :concurrently
  end
end
