class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices, id: :uuid do |t|
      t.references :promo_code,   type: :uuid, foreign_key: true
      t.references :subscription, type: :uuid, foreign_key: true
      t.references :user,         type: :uuid, foreign_key: true

      t.string :description
      t.string :status
      t.string :total

      t.datetime :period_start
      t.datetime :period_end

      t.string :stripe_id
      t.jsonb  :stripe_object

      t.timestamps
    end

    add_index :invoices, :status
    add_index :invoices, :stripe_id, unique: true
  end
end
