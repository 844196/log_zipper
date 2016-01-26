require 'spec_helper'
require 'tempfile'

describe LogZipper::Encode do
  before do
    @file = Tempfile.open('log_zipper_test').tap {|tmp| File.open(tmp, 'wb') {|f| f.write file } }
  end
  after { @file.unlink }

  describe '.utf8block' do
    context 'エンコードがShift_JISのYAMLを読み込んだ場合' do
      let(:file) { "export_file_suffix: '\x83e\x83X\x83g'\r\n" }

      before { LogZipper.yaml_load :path => @file.path }

      it '価が反映されること' do
        expect(LogZipper.config.to_h).to include(:export_file_suffix => 'テスト')
      end
    end
  end
end
