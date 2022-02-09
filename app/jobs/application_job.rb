class ApplicationJob < ActiveJob::Base
  # 1 retry by default
  sidekiq_options retry: 1

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
