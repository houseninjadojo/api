class RemoveIndexFromDocumentTags < ActiveRecord::Migration[7.0]
  def change
    remove_index :documents, :tags
  end
end
