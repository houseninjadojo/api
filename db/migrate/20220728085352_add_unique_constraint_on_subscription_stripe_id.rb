class AddUniqueConstraintOnSubscriptionStripeId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :subscriptions, :stripe_id, unique: true, algorithm: :concurrently
  end
end
