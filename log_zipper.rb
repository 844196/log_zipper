# vim:fileencoding=utf-8:

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_zipper'

config = LogZipper.config
arg = ARGV[0].encode('UTF-8')

log = LogZipper::Log.new(arg).tap do |export|
  export.rows.map! {|row| CSV::Row.new(config.export_fields, config.export_fields.map {|field| row[field] }) }
  export.rows.sort_by! {|row| config.export_sort_order.map {|field| row[field] } }
  export.name << config.export_file_suffix
end

File.open(log.path, 'wb') do |csv|
  csv.print UTF8_BOM = "\xEF\xBB\xBF"
  csv.print log.to_csv
end
