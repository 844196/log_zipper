# vim:fileencoding=utf-8:

module LogZipper
  class Log
    attr_accessor :dir, :name, :ext, :rows

    def initialize(original_path)
      @dir, basename, @ext = File.split(original_path).tap {|ary| ary << File.extname(ary[1]) }
      @name = File.basename(basename, @ext)
      @rows = LogZipper::CSV.import(path)
    end

    def path
      File.join(@dir, @name + @ext)
    end

    def to_csv
      ::CSV::Table.new(@rows).to_csv
    end

    def convert(&block)
      label = LogZipper.config.field_label
      sort_rows [label['client'], label['time'], label['user']]
      rows_zip
      yield self if block_given?
    end

    def rows_zip
      label = LogZipper.config.field_label
      out = []
      out << find_shift(@rows) {|row| row[label['session']] != rows.first[label['session']] } until @rows.size.zero?
      @rows = out.map {|sessions| cal_uptime(sessions.first, sessions.last) }.compact
    end

    def sort_rows(order)
      @rows.sort_by! {|row| order.map {|field| row[field] } }
    end

    def sort_columns(order)
      @rows.map! {|row| ::CSV::Row.new(order, order.map {|field| row[field] }) }
    end

    private

    def find_shift(array, &block)
      index = array.find_index(&block)
      index ? array.shift(index) : array.slice!(0..-1)
    end

    def cal_uptime(startup, shutdown)
      label = LogZipper.config.field_label

      startup_time  = startup[label['time']]
      shutdown_time = shutdown[label['time']]
      uptime        = Time.at(shutdown_time - startup_time).utc

      startup.tap do |out|
        out[label['uptime']]   = time_to_hms(uptime)
        out[label['time']]     = time_to_hms(startup_time)
        out[label['shutdown']] = time_to_hms(shutdown_time)
      end
    end

    def time_to_hms(time_obj)
      time_obj.strftime('%X')
    end
  end
end
