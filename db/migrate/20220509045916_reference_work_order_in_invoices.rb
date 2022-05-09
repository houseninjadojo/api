class ReferenceWorkOrderInInvoices < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :invoices, :work_order, type: :uuid, index: { algorithm: :concurrently }
  end
end
