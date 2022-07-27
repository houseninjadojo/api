return if Rails.env.test?

# fetch hubspot pipeline with list of dealstages
#
# @return {Hubspot::DealPipeline}
#   <Hubspot::DealPipeline:0x000000010e9e9a30
#   @active=true,
#   @display_order=1,
#   @label="Work Orders",
#   @pipeline_id="2133042",
#   @stages=
#    [
#      {"stageId"=>"7430806", "label"=>"Work Request Received", "probability"=>0.1, "active"=>true, "displayOrder"=>0, "closedWon"=>false},
#      ...
#    ]>
def pipeline(pipeline_id)
  Hubspot::DealPipeline.find(pipeline_id)
end

# get stages
#
# @returns {Array<Hash>}
#   [
#     {"stageId"=>"7430806", "label"=>"Work Request Received", "probability"=>0.1, "active"=>true, "displayOrder"=>0, "closedWon"=>false},
#     ...
#   ]
#
def stages(pipeline_id)
  pipeline(pipeline_id).stages
end

# map to model attributes
#
# @returns {Array<Hash>}
#   [
#     { :hubspot_id => "7430806", :name => "Work Request Received", :slug => "work_request_received" }
#   ]
def mapped_stages(pipeline_id)
  stages(pipeline_id).map do |stage|
    {
      name: stage["label"],
      hubspot_id: stage["stageId"],
      slug: stage["label"].gsub(' ', '_').downcase,
    }
  end
end

# load into database
def map_and_save_stages(pipeline_id)
  stages = mapped_stages(pipeline_id).map do |status|
    {
      hubspot_id: status[:hubspot_id],
      name: status[:name],
      slug: status[:slug],
      hubspot_pipeline_id: pipeline_id,
    }
  end
  WorkOrderStatus.upsert_all(stages, unique_by: [:slug])
end

pipelines = [
  2133042, # Work Orders
  6430329, # Home Walkthroughs
]

pipelines.each do |pipeline_id|
  map_and_save_stages(pipeline_id)
end
