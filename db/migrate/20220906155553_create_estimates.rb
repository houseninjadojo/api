class CreateEstimates < ActiveRecord::Migration[7.0]
  def change
    create_table :estimates, id: :uuid do |t|
      t.references :work_order, type: :uuid, foreign_key: true, null: false

      t.string :homeowner_amount
      t.string :homeowner_amount_actual
      t.string :vendor_amount

      t.text :description
      t.string :vendor_name
      t.string :vendor_category

      t.datetime :scheduled_at
      t.datetime :scheduled_window_start
      t.datetime :scheduled_window_end
      t.datetime :shared_at
      t.datetime :approved_at

      t.timestamps
    end

    add_index :estimates, :approved_at
    add_index :estimates, :shared_at
  end
end
