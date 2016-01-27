# vim:fileencoding=utf-8:

module LogZipper
  class Logger
    include Singleton
    attr_reader :log

    def initialize
      @log = ::Logger.new(STDERR)
      @log.progname = 'LogZipper'
      @log.level = ::Logger::WARN
    end
  end

  class << self
    def logger
      LogZipper::Logger.instance.log
    end
  end
end
