
#
# Specifying scorn
#
# Tue Jan  5 11:01:09 JST 2021
#

require 'pp'
#require 'ostruct'

require 'scorn'


module Helpers

  #def jruby?; !! RUBY_PLATFORM.match(/java/); end
  #def windows?; Gem.win_platform?; end
end # Helpers

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

