class AddInvoiceNotesToWorkOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :work_orders, :invoice_notes, :text
  end
end
