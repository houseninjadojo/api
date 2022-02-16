class ValidateAddForeignKeyToSubscriptionsPromoCode < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :subscriptions, :promo_codes
  end
end
