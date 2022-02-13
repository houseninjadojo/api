class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.references :user,     type: :uuid, foreign_key: true
      t.references :invoice,  type: :uuid, foreign_key: true
      t.references :property, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
