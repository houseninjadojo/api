class Sync::Invoice::Stripe::Outbound::UpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
