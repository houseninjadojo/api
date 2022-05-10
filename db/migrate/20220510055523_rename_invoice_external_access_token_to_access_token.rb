class RenameInvoiceExternalAccessTokenToAccessToken < ActiveRecord::Migration[7.0]
  def change
    safety_assured { rename_column :invoices, :external_access_token, :access_token }
  end
end
