# vim:fileencoding=utf-8:

require 'kconv'
require 'csv'
require 'time'

raise 'please specified input csv path' unless ARGV[0]
input_csv_dir, input_csv_name = File.split(ARGV[0].encode('UTF-8'))
input_csv_path = File.join(input_csv_dir, input_csv_name)
output_csv_name = "#{File.basename(input_csv_name, '.csv')}_修正済み2.csv"
output_csv_path = File.join(input_csv_dir, output_csv_name)

input_records = nil
File.open(input_csv_path) do |original|
  encode = Kconv.guess(original.read).name
  input_records = CSV.read(original.path, "rb:BOM|#{encode}:UTF-8", :headers => true, :skip_blanks => true).map(&:to_h)
    .tap {|ary| ary.each {|row| row['ｲﾍﾞﾝﾄ時刻'] = Time.local(2000, 1, 1, *"#{row['ｲﾍﾞﾝﾄ時刻']}".split(/[\/\-\s:]/).map(&:to_i)) } }
    .tap {|ary| ary.each {|row| row['ｾｯｼｮﾝID'] ||= "#{row['ｴｰｼﾞｪﾝﾄ']}_#{row['ﾛｸﾞｵﾝﾕｰｻﾞｰ']}" } }
    .sort_by! {|row| [row['ｴｰｼﾞｪﾝﾄ'], row['ｲﾍﾞﾝﾄ時刻'], row['ﾛｸﾞｵﾝﾕｰｻﾞｰ']] }
end

output_records = []
loop do
  begin
    i = input_records.find_index {|row| row['ｾｯｼｮﾝID'] != input_records.first['ｾｯｼｮﾝID'] }
    output_records << input_records.shift(i)
  rescue
    output_records << input_records
    break
  end
end

output_records.map! {|record|
  uptime = record.last['ｲﾍﾞﾝﾄ時刻'] - record.first['ｲﾍﾞﾝﾄ時刻']
  unless uptime.zero?
    record.first.merge('ｲﾍﾞﾝﾄ時刻' => record.first['ｲﾍﾞﾝﾄ時刻'].strftime('%X'),
                       '終了時刻'  => record.last['ｲﾍﾞﾝﾄ時刻'].strftime('%X'),
                       '稼働時間'  => Time.at(uptime).utc.strftime('%X'))
  end
}.compact!
output_records.sort_by! {|row| [row['ｲﾍﾞﾝﾄ時刻'], row['終了時刻']] }

case output_records.size
when 0
  File.open(output_csv_path, 'wb') do |file|
    file.puts 'No Record'
  end
  exit 1
else
  File.open(output_csv_path, 'wb') {|f| f.print("\xEF\xBB\xBF") }
  CSV.open(output_csv_path, 'ab') do |csv|
    csv << output_records.first.keys
    output_records.each do |record|
      csv << record.values
    end
  end
end
