# vim:fileencoding=utf-8:

module LogZipper::CSV
  class << self
    def import(csv_path)
      label = LogZipper.config.field_label
      table = []

      LogZipper::Encode.utf8block(csv_path) do |file|
        LogZipper.logger.info(self) { "start: #{file.path}" }

        ::CSV.foreach(file, :headers => true, :skip_blanks => true) do |row|
          row[label['time']] = to_time(row[label['date']], row[label['time']])
          row[label['session']] ||= to_session(row[label['client']], row[label['user']])
          LogZipper.logger.debug(self) { "import: #{row.inspect}" }
          table << row
        end

        LogZipper.logger.info(self) { "finish, imported table size: #{table.size}" }
      end

      table
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
