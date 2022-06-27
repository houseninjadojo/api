class AddWorkorderAttributes < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :homeowner_amount_actual, :string
    add_column :work_orders, :customer_approved_work, :boolean
    add_column :work_orders, :walkthrough_date, :datetime
    add_column :work_orders, :walkthrough_time, :string
    add_column :work_orders, :completed_at, :datetime
    add_column :work_orders, :refund_amount, :string
    add_column :work_orders, :refund_reason, :string
  end
end
