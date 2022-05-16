class AddForeignKeyToInvoiceWorkOrderId < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :invoices, :work_orders, column: :work_order_id, on_delete: :cascade, validate: false
  end
end
