# vim:fileencoding=utf-8:

module LogZipper
  class Log
    include LogZipper::Function
    attr_accessor :dir, :name, :ext, :rows

    def initialize(path)
      @dir, basename, @ext = File.split(path).tap {|ary| ary << File.extname(ary[1]) }
      @name = File.basename(basename, @ext)
      @rows = rows_zip(import_csv(path))
    end

    def path
      File.join(@dir, @name + @ext)
    end

    def to_csv
      CSV::Table.new(@rows).to_csv
    end
  end
end
