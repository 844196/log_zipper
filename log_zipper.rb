# vim:fileencoding=utf-8:

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log_zipper'
require 'optparse'

params = {}
args = ARGV.map {|arg| arg.encode('UTF-8') }

OptionParser.new do |opt|
  opt.banner = "Usage: #{File.basename(__FILE__)} [OPTIONS] <FILE1> <FILE2>..."
  opt.version = LogZipper::VERSION
  opt.on('-y', '--yaml=<PATH>', 'specifie user config.yml path') {|v| params[:yaml_path] = v }
  opt.on('-l', '--log-level=<LEVEL>', 'specifie log level (default: WARN)') {|v| params[:log_level] = v.upcase }
  opt.on('-d', '--dry-run', TrueClass) {|v| params[:dry_run] = v }
  opt.parse!(args)
end

args.each do |path|
  LogZipper.logger.level = eval("Logger::#{params[:log_level]}") if params[:log_level]
  LogZipper.yaml_load :path => params[:yaml_path] if params[:yaml_path]

  log = LogZipper::Log.new(path)
  log.convert do |additional|
    additional.sort_rows    LogZipper.config.export_sort_order
    additional.sort_columns LogZipper.config.export_fields
  end
  log.name << LogZipper.config.export_file_suffix

  (puts log.to_csv; next) if params[:dry_run]

  File.open(log.path, 'wb') do |csv|
    csv.print UTF8_BOM = "\xEF\xBB\xBF"
    csv.print log.to_csv
  end
end
