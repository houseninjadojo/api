# frozen_string_literal: true

ActiveJob::Uniqueness.configure do |config|
  # Global default expiration for lock keys. Each job can define its own ttl via :lock_ttl option.
  # Stategy :until_and_while_executing also accept :on_runtime_ttl option.
  #
  # config.lock_ttl = 1.day

  # Prefix for lock keys. Can not be set per job.
  #
  # config.lock_prefix = 'activejob_uniqueness'

  # Default action on lock conflict. Can be set per job.
  # Stategy :until_and_while_executing also accept :on_runtime_conflict option.
  # Allowed values are
  #   :raise - raises ActiveJob::Uniqueness::JobNotUnique
  #   :log - instruments ActiveSupport::Notifications and logs event to the ActiveJob::Logger
  #   proc - custom Proc. For example, ->(job) { job.logger.info("Job already in queue: #{job.class.name} #{job.arguments.inspect} (#{job.job_id})") }
  #
  config.on_conflict = ->(job) {
    job.logger.warn(
      "Job already in queue: #{job.class.name} (#{job.job_id})",
      message: "Job already in queue: #{job.class.name} (#{job.job_id})",
      payload: {
        adapter: "Sidekiq",
        arguments: job.arguments.inspect,
        job_id: job.job_id,
        job_class: job.class.name,
        queue_name: job.queue_name,
        provider_job_id: job.provider_job_id,
        enqueued: false
      }
    )
  }

  # Digest method for lock keys generating. Expected to have `hexdigest` class method.
  #
  # config.digest_method = OpenSSL::Digest::MD5

  # Array of redis servers for Redlock quorum.
  # Read more at https://github.com/leandromoreira/redlock-rb#redis-client-configuration
  #
  if Rails.env.production? || Rails.env.sandbox?
    config.redlock_servers = [
      Redis.new(
        url: ENV.fetch('REDIS_URL', 'redis://localhost:6379'),
        ssl_params: {
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        }
      ),
    ]
  end

  # Custom options for Redlock.
  # Read more at https://github.com/leandromoreira/redlock-rb#redlock-configuration
  #
  # config.redlock_options = { retry_count: 0 }

  # Custom strategies.
  # config.lock_strategies = { my_strategy: MyStrategy }
  #
  # config.lock_strategies = {}
end
