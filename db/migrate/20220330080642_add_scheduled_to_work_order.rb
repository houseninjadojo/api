class AddScheduledToWorkOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :scheduled_window_start, :datetime
    add_column :work_orders, :scheduled_window_end,   :datetime
  end
end
