# vim:fileencoding=utf-8:

module LogZipper
  class Configuration
    include Singleton

    @@defaults = {
      :field_label => {'client'   => 'ｴｰｼﾞｪﾝﾄ',
                       'user'     => 'ﾛｸﾞｵﾝﾕｰｻﾞｰ',
                       'date'     => '日付',
                       'time'     => 'ｲﾍﾞﾝﾄ時刻',
                       'shutdown' => '終了時刻',
                       'uptime'   => '稼働時間',
                       'session'  => 'ｾｯｼｮﾝID'},
      :export_fields => %w[ｴｰｼﾞｪﾝﾄ ﾛｸﾞｵﾝﾕｰｻﾞｰ 日付 ｲﾍﾞﾝﾄ時刻 終了時刻 稼働時間],
      :export_sort_order => %w[ｲﾍﾞﾝﾄ時刻 終了時刻],
      :export_file_suffix => '_修正済み2'
    }

    def initialize
      @@defaults.each {|k,v| self.send("#{k}=", v) }
    end

    def defaults
      @@defaults
    end

    attr_accessor(*@@defaults.keys)
  end

  class << self
    def config
      Configuration.instance
    end

    def configure
      yield(config)
    end

    def yaml_load(path: nil)
      YAML.load_file(path).each {|k,v| config.send("#{k}=", v) }
    end
  end
end
