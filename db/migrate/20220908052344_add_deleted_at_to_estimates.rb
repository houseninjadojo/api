class AddDeletedAtToEstimates < ActiveRecord::Migration[7.0]
  def change
    add_column :estimates, :deleted_at, :datetime, index: true
  end
end
