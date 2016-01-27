require 'spec_helper'
require 'tempfile'

describe LogZipper::Logger do
  after { LogZipper.logger.level = ::Logger::WARN }

  describe '表示テスト' do
    before do
      @csv = Tempfile.open('log_zipper_test')
      File.open(@csv, 'wb') do |f|
        f.write <<-EOS.tap {|yml| m = yml.scan(/^\s*/).map(&:length).min; break yml.gsub(/^\s{#{m}}/, '') }
          "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
          PC004,User4,2000/01/01,00:04:00
          PC004,User4,2000/01/01,00:05:00
          PC004,User4,2000/01/01,00:06:00
          PC003,User3,2000/01/01,00:07:00
          PC004,User4,2000/01/01,00:07:00
          PC003,User3,2000/01/01,00:08:00
          PC003,User3,2000/01/01,00:09:00
        EOS
      end
    end
    after { @csv.unlink }

    it 'loglevel: info' do
      LogZipper.logger.level = ::Logger::INFO
      log = LogZipper::Log.new(@csv.path)
      log.convert do |opt|
        opt.sort_rows    %w[日付 ｲﾍﾞﾝﾄ時刻 終了時刻]
        opt.sort_columns %w[ｴｰｼﾞｪﾝﾄ ﾛｸﾞｵﾝﾕｰｻﾞｰ 日付 ｲﾍﾞﾝﾄ時刻 終了時刻 稼働時間]
      end
    end

    it 'loglevel: debug' do
      LogZipper.logger.level = ::Logger::DEBUG
      log = LogZipper::Log.new(@csv.path)
      log.convert do |opt|
        opt.sort_rows    %w[日付 ｲﾍﾞﾝﾄ時刻 終了時刻]
        opt.sort_columns %w[ｴｰｼﾞｪﾝﾄ ﾛｸﾞｵﾝﾕｰｻﾞｰ 日付 ｲﾍﾞﾝﾄ時刻 終了時刻 稼働時間]
      end
    end
  end
end
