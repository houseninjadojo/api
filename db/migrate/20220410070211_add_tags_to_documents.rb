class AddTagsToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :tags, :string, array: true, default: [], null: false
  end
end
