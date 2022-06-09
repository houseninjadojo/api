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
def pipeline
  Hubspot::DealPipeline.find("2133042")
end

# get stages
#
# @returns {Array<Hash>}
#   [
#     {"stageId"=>"7430806", "label"=>"Work Request Received", "probability"=>0.1, "active"=>true, "displayOrder"=>0, "closedWon"=>false},
#     ...
#   ]
#
def stages
  pipeline.stages
end

# map to model attributes
#
# @returns {Array<Hash>}
#   [
#     { :hubspot_id => "7430806", :name => "Work Request Received", :slug => "work_request_received" }
#   ]
def mapped_stages
  stages.map do |stage|
    {
      name: stage["label"],
      hubspot_id: stage["stageId"],
      slug: stage["label"].gsub(' ', '_').downcase,
    }
  end
end

# load into database
mapped_stages.each do |status|
  WorkOrderStatus.find_or_create_by(hubspot_id: status[:hubspot_id]) do |work_order_status|
    work_order_status.name = status[:name]
    work_order_status.slug = status[:slug]
  end
end
