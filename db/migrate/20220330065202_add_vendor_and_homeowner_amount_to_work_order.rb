class AddVendorAndHomeownerAmountToWorkOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :homeowner_amount, :string
    add_column :work_orders, :vendor_amount, :string
  end
end
