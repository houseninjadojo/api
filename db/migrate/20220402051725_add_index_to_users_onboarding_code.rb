class AddIndexToUsersOnboardingCode < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :users, :onboarding_code, unique: true, algorithm: :concurrently
  end
end
