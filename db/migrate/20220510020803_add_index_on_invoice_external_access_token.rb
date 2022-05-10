class AddIndexOnInvoiceExternalAccessToken < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :invoices, :external_access_token, unique: true, algorithm: :concurrently
  end
end
