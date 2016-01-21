# vim:fileencoding=utf-8:

module LogZipper::Function
  private

  def import_csv(csv_path)
    File.open(csv_path) do |original|
      encode = Kconv.guess(original.read).name
      label = LogZipper.config.field_label
      CSV.read(original.path, "rb:BOM|#{encode}:UTF-8", :headers => true, :skip_blanks => true)
        .map {|row|
          row[label['time']] = Time.local(*"#{row[label['date']]} #{row[label['time']]}".split(/[\/\-\s:]/).map(&:to_i))
          row[label['session']] ||= "#{row[label['client']]}_#{row[label['user']]}"
          row
        }.sort_by {|row| [row[label['client']], row[label['time']], row[label['user']]] }
    end
  end

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
    return nil unless shutdown
    label = LogZipper.config.field_label
    startup.dup.tap do |out|
      out[label['uptime']]   = time_to_hms(Time.at(shutdown[label['time']] - startup[label['time']]).utc)
      out[label['time']]     = time_to_hms(startup[label['time']])
      out[label['shutdown']] = time_to_hms(shutdown[label['time']])
    end
  end

  def time_to_hms(time_obj)
    time_obj.strftime('%X')
  end
end
