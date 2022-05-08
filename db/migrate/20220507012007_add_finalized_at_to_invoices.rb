class AddFinalizedAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :finalized_at, :timestamp
  end
end
