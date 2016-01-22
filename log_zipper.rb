# vim:fileencoding=utf-8:

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_zipper'

config = LogZipper.config
arg = ARGV[0].encode('UTF-8')

log = LogZipper::Log.new(arg)

log.convert do |additional|
  additional.sort_rows    config.export_sort_order
  additional.sort_columns config.export_fields
end
log.name << config.export_file_suffix

File.open(log.path, 'wb') do |csv|
  csv.print UTF8_BOM = "\xEF\xBB\xBF"
  csv.print log.to_csv
end
