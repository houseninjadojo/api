class AddAccessTokenToEstimates < ActiveRecord::Migration[7.0]
  def change
    add_column :estimates, :access_token, :string, unique: true, index: true
  end
end
