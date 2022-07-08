class AddPipelineIdToWorkOrderStatuses < ActiveRecord::Migration[7.0]
  def change
    add_column :work_order_statuses, :hubspot_pipeline_id, :string
  end
end
