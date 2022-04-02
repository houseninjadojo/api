class AddCustomerTypeAndOnboardingStepToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :contact_type, :string, index: true
    add_column :users, :onboarding_step, :string
  end
end
