class SetDefaultContactTypeOnUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :contact_type, :string, default: 'Customer'
  end
end
