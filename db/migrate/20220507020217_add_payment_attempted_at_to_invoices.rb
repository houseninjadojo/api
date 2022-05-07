class AddPaymentAttemptedAtToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :payment_attempted_at, :timestamp
  end
end
