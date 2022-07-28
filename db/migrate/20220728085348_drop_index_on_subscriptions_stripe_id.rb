class DropIndexOnSubscriptionsStripeId < ActiveRecord::Migration[7.0]
  def change
    remove_index :subscriptions, :stripe_id
  end
end
