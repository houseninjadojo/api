class ChangeDocumentTagsColumnToTextArray < ActiveRecord::Migration[7.0]
  def change
    change_column :documents, :tags, :text, array: true, default: [], null: false
  end
end
