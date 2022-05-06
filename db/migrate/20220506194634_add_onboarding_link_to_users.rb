class AddOnboardingLinkToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :onboarding_link, :string
  end
end
