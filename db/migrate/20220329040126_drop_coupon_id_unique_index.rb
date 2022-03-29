class DropCouponIdUniqueIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :promo_codes, :coupon_id
  end
end
