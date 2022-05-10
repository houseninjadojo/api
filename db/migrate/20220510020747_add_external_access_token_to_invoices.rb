class AddExternalAccessTokenToInvoices < ActiveRecord::Migration[7.0]
  def change
    add_column :invoices, :external_access_token, :string
  end
end
