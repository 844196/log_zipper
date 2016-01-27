# vim:fileencoding=utf-8:

module LogZipper::Encode
  def self.utf8block(path, &block)
    LogZipper.logger.debug(self) { "start" }

    temp = Tempfile.open('LogZipper')
    File.open(path, 'rb') do |original|
      encode = Kconv.guess(original.read).name
      LogZipper.logger.debug(self) { "original file encoding: #{encode}" }

      File.open(temp, 'wb') {|f| f.write File.open(path, "rb:#{encode}:UTF-8").read }
      LogZipper.logger.debug(self) { "converted tempfile: #{temp.path}" }
    end
    LogZipper.logger.debug(self) { "finish" }

    block.call(temp)
  ensure
    temp.unlink
    LogZipper.logger.debug(self) { "delete tempfile" }
  end
end
