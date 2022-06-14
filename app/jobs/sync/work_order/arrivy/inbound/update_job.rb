class Sync::WorkOrder::Arrivy::Inbound::UpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
