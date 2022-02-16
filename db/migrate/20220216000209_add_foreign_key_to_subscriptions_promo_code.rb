class AddForeignKeyToSubscriptionsPromoCode < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :subscriptions, :promo_codes, validate: false
  end
end
