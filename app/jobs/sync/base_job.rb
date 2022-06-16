class Sync::BaseJob < ApplicationJob
  sidekiq_options retry: 0
  queue_as :default
end
