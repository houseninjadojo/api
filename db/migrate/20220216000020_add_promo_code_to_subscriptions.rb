class AddPromoCodeToSubscriptions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :subscriptions, :promo_code, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end
