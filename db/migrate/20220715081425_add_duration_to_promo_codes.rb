class AddDurationToPromoCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :promo_codes, :duration, :string
    add_column :promo_codes, :duration_in_months, :integer
  end
end
