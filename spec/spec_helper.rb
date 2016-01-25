RSpec.configure do |config|
  config.before(:suite) { puts "\e[H\e[2J" }
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'log_zipper'
