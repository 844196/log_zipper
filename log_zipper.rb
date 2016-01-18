require 'csv'
require 'time'

input_records = CSV.parse(DATA, :headers => true, :skip_blanks => true)
  .tap {|ary| ary.each {|row| row['ｲﾍﾞﾝﾄ時刻'] = Time.local(2000, 1, 1, *"#{row['ｲﾍﾞﾝﾄ時刻']}".split(/[\/\-\s:]/).map(&:to_i)) } }
  .tap {|ary| ary.each {|row| row['ｾｯｼｮﾝID'] ||= "#{row['ｴｰｼﾞｪﾝﾄ']}_#{row['ﾛｸﾞｵﾝﾕｰｻﾞ']}" } }
  .map(&:to_h)
  .sort_by! {|row| [row['ｴｰｼﾞｪﾝﾄ'], row['ｲﾍﾞﾝﾄ時刻'], row['ﾛｸﾞｵﾝﾕｰｻﾞ']] }

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

puts output_records.first.keys.join(',')
output_records.each do |record|
  puts record.values.join(',')
end

__END__
ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞ,日付,ｲﾍﾞﾝﾄ時刻
clientG,userA,2000/1/1,15:01:00
clientG,userA,2000/1/1,15:02:00
clientG,userA,2000/1/1,15:03:00
clientG,userA,2000/1/1,15:04:00
clientW,userB,2000/1/1,14:01:00
clientW,userB,2000/1/1,14:02:00
clientW,userB,2000/1/1,14:03:00
clientW,userB,2000/1/1,14:04:00
