
#
# Specifying scorn
#
# Tue Jan  5 11:01:09 JST 2021
#

require 'pp'
#require 'ostruct'

require 'scorn'


class RequestDebugger
  attr_reader :a
  def initialize
    @a = []
  end
  def <<(s)
    @a << s
  end
  def to_s
    @a.join("\n")
  end
  def request_lines
    l = @a.find { |s| s.match(/\A"(GET|POST|HEAD|PUT|DELETE) /) }
    l.split('\r\n')
  end
  def request_headers
    request_lines
      .inject([]) { |a, l|
        m = l.match(/\A([-a-zA-Z0-9]+): (.+)\z/)
        a << [ m[1], m[2] ] if m
        a }
  end
end

class Probatio::Context
end

