class AddOnboardingTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :onboarding_code, :string
  end
end
