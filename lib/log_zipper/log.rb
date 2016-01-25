# vim:fileencoding=utf-8:

module LogZipper
  class Log
    include LogZipper::Function
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
      @rows = rows_zip(@rows)
      yield self if block_given?
    end

    def sort_rows(order)
      @rows.sort_by! {|row| order.map {|field| row[field] } }
    end

    def sort_columns(order)
      @rows.map! {|row| ::CSV::Row.new(order, order.map {|field| row[field] }) }
    end
  end
end
