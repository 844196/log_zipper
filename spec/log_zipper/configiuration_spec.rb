require 'spec_helper'
require 'tempfile'

describe LogZipper::Configuration do
  before do
    data = yaml.tap {|yml| m = yml.scan(/^\s*/).map(&:length).min; break yml.gsub(/^\s{#{m}}/, '') }
    @yaml = Tempfile.open('log_zipper_test').tap {|tmp| File.open(tmp, 'wb') {|f| f.write data } }
  end
  after { @yaml.unlink }

  describe 'YAML読み込み' do
    context 'デフォルト値に存在しないキーがYAMLに記述されている場合' do
      let(:yaml) {
        <<-YAML
        sushi: tabetai
        YAML
      }

      before { LogZipper.yaml_load :path => @yaml.path }

      it '例外が発生しないこと' do
        expect {}.not_to raise_error
      end

      it 'デフォルト値に存在しないキーは無視されること' do
        expect(LogZipper.config.instance_variables).not_to include :@sushi
      end
    end
  end
end
