class AddNameAndDescriptionToDocuments < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :name, :string
    add_column :documents, :description, :string
  end
end
