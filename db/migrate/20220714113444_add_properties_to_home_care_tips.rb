class AddPropertiesToHomeCareTips < ActiveRecord::Migration[7.0]
  def change
    add_column :home_care_tips, :week, :integer
    add_column :home_care_tips, :time_of_year, :string
    add_column :home_care_tips, :service_provider, :string
    add_column :home_care_tips, :other_provider, :string
  end
end
