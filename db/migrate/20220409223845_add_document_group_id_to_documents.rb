class AddDocumentGroupIdToDocuments < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :documents, :document_group, type: :uuid, index: { algorithm: :concurrently }
  end
end
