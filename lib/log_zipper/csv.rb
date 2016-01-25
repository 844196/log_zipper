# vim:fileencoding=utf-8:

module LogZipper::CSV
  class << self
    def import(csv_path)
      table = []
      File.open(csv_path) do |original|
        encode = Kconv.guess(original.read).name
        table = ::CSV.read(original.path, "rb:BOM|#{encode}:UTF-8", :headers => true, :skip_blanks => true)
      end

      label = LogZipper.config.field_label
      table.map do |row|
        row[label['time']] = to_time(row[label['date']], row[label['time']])
        row[label['session']] ||= to_session(row[label['client']], row[label['user']])
        row
      end
    end

    private

    def to_time(date, time)
      Time.local(*date.split(/[\/\-]/).map(&:to_i), *time.split(/:/).map(&:to_i))
    end

    def to_session(client, user)
      [client, user].join('_')
    end
  end
end
