require 'spec_helper'
require 'tempfile'

describe 'End to End' do
  before do
    input, @expected = data.gsub(/^\s+/, '').split(/===\n/)
    @csv = Tempfile.open('log_zipper_test')
    File.open(@csv, 'wb') {|f| f.write(input) }
    @log = LogZipper::Log.new(@csv.path).tap do |log|
      log.convert do |opt|
        opt.sort_rows    %w[日付 ｲﾍﾞﾝﾄ時刻 終了時刻]
        opt.sort_columns %w[ｴｰｼﾞｪﾝﾄ ﾛｸﾞｵﾝﾕｰｻﾞｰ 日付 ｲﾍﾞﾝﾄ時刻 終了時刻 稼働時間]
      end
    end
  end

  after do
    @csv.unlink
  end

  subject { @log.to_csv }

  context '起動〜終了まで3行' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC001,User1,2000/01/01,00:00:00
        PC001,User1,2000/01/01,00:01:00
        PC001,User1,2000/01/01,00:02:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC001,User1,2000/01/01,00:00:00,00:02:00,00:02:00
      DATA
    }
    it '終了時刻・稼働時間が計算され、1行に折りたたまれること' do
      is_expected.to eq @expected
    end
  end

  context '起動〜終了まで2行' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC001,User2,2000/01/01,00:04:00
        PC001,User2,2000/01/01,00:05:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC001,User2,2000/01/01,00:04:00,00:05:00,00:01:00
      DATA
    }
    it '終了時刻・稼働時間が計算され、1行に折りたたまれること' do
      is_expected.to eq @expected
    end
  end

  context '起動レコードのみ' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC002,User3,2000/01/01,00:06:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC002,User3,2000/01/01,00:06:00,00:06:00,00:00:00
      DATA
    }
    it 'ｲﾍﾞﾝﾄ時刻＝終了時刻、稼働時間0秒のレコードが1行出力されること' do
      is_expected.to eq @expected
    end
  end

  context 'レコードなし' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        ===
      DATA
    }
    it 'ヘッダ行も何も出力されないこと' do
      is_expected.to eq "\n"
    end
  end

  context '2つのセッション' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC004,User4,2000/01/01,00:04:00
        PC004,User4,2000/01/01,00:05:00
        PC004,User4,2000/01/01,00:06:00
        PC003,User3,2000/01/01,00:07:00
        PC004,User4,2000/01/01,00:07:00
        PC003,User3,2000/01/01,00:08:00
        PC003,User3,2000/01/01,00:09:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC004,User4,2000/01/01,00:04:00,00:07:00,00:03:00
        PC003,User3,2000/01/01,00:07:00,00:09:00,00:02:00
      DATA
    }
    it 'それぞれ計算されて2行になること' do
      is_expected.to eq @expected
    end
  end

  context '最初の行が起動レコードのみ' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC005,User5,2000/01/01,00:10:00
        PC006,User6,2000/01/01,00:11:00
        PC006,User6,2000/01/01,00:12:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC005,User5,2000/01/01,00:10:00,00:10:00,00:00:00
        PC006,User6,2000/01/01,00:11:00,00:12:00,00:01:00
      DATA
    }
    it '問題ないこと' do
      is_expected.to eq @expected
    end
  end

  context '最後の行が起動レコードのみ' do
    let(:data) {
      <<-DATA
        "ｴｰｼﾞｪﾝﾄ","ﾛｸﾞｵﾝﾕｰｻﾞｰ","日付","ｲﾍﾞﾝﾄ時刻"
        PC007,User6,2000/01/01,00:11:00
        PC007,User6,2000/01/01,00:12:00
        PC008,User5,2000/01/01,00:13:00
        ===
        ｴｰｼﾞｪﾝﾄ,ﾛｸﾞｵﾝﾕｰｻﾞｰ,日付,ｲﾍﾞﾝﾄ時刻,終了時刻,稼働時間
        PC007,User6,2000/01/01,00:11:00,00:12:00,00:01:00
        PC008,User5,2000/01/01,00:13:00,00:13:00,00:00:00
      DATA
    }
    it '問題ないこと' do
      is_expected.to eq @expected
    end
  end
end
