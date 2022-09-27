class CleanBacktraceFormatter < SemanticLogger::Formatters::Json
  def self.cleaner
    @cleaner ||= begin
      bc = ActiveSupport::BacktraceCleaner.new
      bc.remove_silencers! # remove defaults
      bc.add_silencer { |line| /datadog|sentry|semantic_logger/.match?(line) }
      bc
    end
  end

  # Override SemanticLogger::Formatters::Json#exception
  def exception
    return unless log.exception

    root = hash
    log.each_exception do |exception, i|
      backtrace = self.class.cleaner.clean(exception.backtrace)
      name       = i.zero? ? :exception : :cause
      root[name] = {
        name:        exception.class.name,
        message:     exception.message,
        stack_trace: backtrace
      }
      root = root[name]
    end
  end
end
