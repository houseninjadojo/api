class AddAmountOffToPromoCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :promo_codes, :amount_off, :string
  end
end
