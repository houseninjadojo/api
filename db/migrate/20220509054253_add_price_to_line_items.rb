class AddPriceToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :line_items, :price, :string
  end
end
