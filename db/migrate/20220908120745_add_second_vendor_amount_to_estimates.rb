class AddSecondVendorAmountToEstimates < ActiveRecord::Migration[7.0]
  def change
    add_column :estimates, :second_vendor_amount, :string
  end
end
