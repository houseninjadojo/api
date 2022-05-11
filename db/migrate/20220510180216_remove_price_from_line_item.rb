class RemovePriceFromLineItem < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :line_items, :price }
  end
end
