class AddDeclinedAtToEstimates < ActiveRecord::Migration[7.0]
  def change
    add_column :estimates, :declined_at, :datetime, index: true
  end
end
