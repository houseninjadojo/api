class AddCouponIdToPromoCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :promo_codes, :coupon_id, :string
  end
end
