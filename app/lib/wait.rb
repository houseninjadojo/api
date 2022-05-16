# frozen_string_literal: true
#
# Wait.until { expr }  -- waits until expr is true
# Wait.while { expr }  -- waits while expr is true
#
# Each iteration contains a `sleep(sleep_time)`, where the default sleep time is
# Wait::DEFAULT_SLEEP_TIME (0.1 seconds).
#
# The sleep interval can be specified with the `sleep_time` argument:
#
# Wait.until(sleep_time: 0.5) { expr }
#
#   waits until expr is true, sleeping 0.5 seconds on each iteration
#
# Wait.while(sleep_time: 1, max_time: 15) { expr }
#
#   waits while expr is true, sleeping 1 second each iteration, until 15 seconds
#
# If the time is exceeded, a Wait::Timeout exception is raised.
# If `max_time` is not provided, there is no timeout.
#
# Each iteration increments a counter, which is passed along to the block as
# the first argument.
#
# The blocks can receive two arguments: `counter`, and `timer`, which represent
# the increment counter and the time waited (in seconds as a float)
#
# Wait.until { |counter, time| expr }
# Wait.while { |counter, time| expr }
#
# The `limit` argument sets the maximum number of iterations.  Once the loop
# counter exceeds the limit, the waiting is stopped with a Wait::Limit exception.
#
# The default message for exceptions are:
#
#   Wait::Timeout -- "The wait timeout has been exceeded."
#   Wait::Limit   -- "The wait limit has been exceeded."
#
# The "msg: STRING" argument can be given to override the default message.

class Wait
  class Error   < StandardError ; end
  class TimeoutError < Error ; end
  class LimitError   < Error ; end

  DEFAULT_SLEEP_TIME = 0.1 # how many seconds to sleep each iteration

  def self.until(**args)
    new(**args).until { |counter, time| yield(counter, time) }
  end

  def self.while(**args)
    new(**args).while { |counter, time| yield(counter, time) }
  end

  VALID_KEYWORDS = %i[max_time sleep_time limit msg].freeze

  attr_reader :max_time, :limit, :msg

  def initialize(**args)
    check_args(args)
    @max_time   = args.delete(:max_time)
    @sleep_time = args.delete(:sleep_time)
    @limit      = args.delete(:limit)
    @msg        = args.delete(:msg)
  end

  private

  def check_args(args)
    extra_keys = (args.keys - VALID_KEYWORDS).map(&:to_s)
    if extra_keys.size.nonzero?
      who_called = caller_locations[1].label
      raise ArgumentError, "#{who_called}: invalid keyword argument(s): #{extra_keys.join(', ')}"
    end
  end

  public

  def while
    run { |counter, time| !yield(counter, time) }
  end

  def until
    run { |counter, time| yield(counter, time) }
  end

  private

  def sleep_time
    @sleep_time ||= DEFAULT_SLEEP_TIME
  end

  def run
    counter = 0
    time_start = Time.now
    result = nil
    while true
      time_waited = (Time.now - time_start).to_f
      check_limit(counter)    if limit
      check_time(time_waited) if max_time
      return result if (result = yield(counter, time_waited))

      sleep(sleep_time)
      counter += 1
    end
  end

  def check_limit(counter)
    raise(LimitError, msg || "Wait limit has been exceeded.") if counter > limit
  end

  def check_time(time_waited)
    raise(TimeoutError, msg || "Wait time has been exceeded.") if time_waited > max_time
  end
end
