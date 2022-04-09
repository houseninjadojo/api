class CreateDocumentGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :document_groups, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string :name, null: false
      t.string :description
      
      t.timestamps
    end
  end
end
