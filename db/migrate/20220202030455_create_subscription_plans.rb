class CreateSubscriptionPlans < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_plans, id: :uuid do |t|
      t.string :slug, null: false, index: :unique
      t.string :name, null: false
      t.string :price, null: false
      t.string :interval, null: false, index: true
      t.string :perk, default: ""

      t.timestamps
    end
  end
end
