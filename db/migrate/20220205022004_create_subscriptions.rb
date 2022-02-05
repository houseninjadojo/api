class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :payment_method,    null: false, foreign_key: true, type: :uuid
      t.references :subscription_plan, null: false, foreign_key: true, type: :uuid
      t.references :user,              null: false, foreign_key: true, type: :uuid

      t.string :stripe_subscription_id, index: true
      t.string :status

      t.datetime :canceled_at

      t.datetime :trial_start
      t.datetime :trial_end

      t.datetime :current_period_start
      t.datetime :current_period_end

      t.timestamps
    end
  end
end
