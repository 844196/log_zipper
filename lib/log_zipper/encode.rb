# vim:fileencoding=utf-8:

module LogZipper::Encode
  def self.utf8block(path, &block)
    temp = Tempfile.open('LogZipper')

    File.open(path, 'rb') do |original|
      encode = Kconv.guess(original.read).name
      File.open(temp, 'wb') {|f| f.write File.open(path, "rb:#{encode}:UTF-8").read }
    end

    block.call(temp)
  ensure
    temp.unlink
  end
end
