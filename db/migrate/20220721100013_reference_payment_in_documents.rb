class ReferencePaymentInDocuments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :documents, :payment, type: :uuid, index: { algorithm: :concurrently }
  end
end
