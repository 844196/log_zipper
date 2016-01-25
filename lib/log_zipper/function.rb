# vim:fileencoding=utf-8:

module LogZipper::Function
  private

  def rows_zip(rows)
    label = LogZipper.config.field_label
    out = []
    out << find_shift(rows) {|row| row[label['session']] != rows.first[label['session']] } until rows.size.zero?
    out.map {|sessions| cal_uptime(sessions.first, sessions.last) }.compact
  end

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
