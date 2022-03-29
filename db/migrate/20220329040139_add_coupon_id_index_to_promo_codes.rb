class AddCouponIdIndexToPromoCodes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :promo_codes, :coupon_id, unique: false, algorithm: :concurrently
  end
end
