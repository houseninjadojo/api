class ValidateAddForeignKeyToInvoiceWorkOrderId < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :invoices, :work_orders
  end
end
