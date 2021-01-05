
require 'json'
require 'time'
require 'base64'
require 'webrick' # for the http code to message mapping
require 'ostruct'
require 'openssl'
require 'net/http'


module Scorn

  VERSION = '0.1.0'

  class << self

    def get(uri, opts={})

      res = Scorn::Client.new(opts).get(uri, opts)

      s = res.body

      st = s.strip
      return (JSON.parse(st) rescue s) if st[0, 1] == '{' && st[-1, 1] == '}'

      s
    end
  end

  class Client

    attr_accessor :user_agent, :ssl_verify_mode

    def initialize(opts)

      @opts = opts

      @user_agent =
        opts[:user_agent] ||
        "Scorn #{VERSION} - " +
        [ 'Ruby', RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM ].join(' ')

      @ssl_verify_mode =
        (opts[:ssl_verify_none] == :none || opts[:verify_none] == :none) ?
        OpenSSL::SSL::VERIFY_NONE : # :-(
        OpenSSL::SSL::VERIFY_PEER
    end

    def get(uri, opts)

      request(uri, make_get_req(uri, opts))
    end

    protected

    def make_get_req(uri, opts)

      req = Net::HTTP::Get.new(uri.to_s)
      req.instance_eval { @header.clear }
      def req.set_header(k, v); @header[k] = [ v ]; end

      req.set_header('User-Agent', user_agent)
      #req.set_header('Accept', 'application/json')

      req
    end

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end

    def request(uri, req)

      u = uri.is_a?(String) ? URI(uri) : uri

      t0 = monow

      http = make_net_http(u)
#t.set_debug_output($stdout) if u.to_s.match?(/search/)

      res = http.request(req)

      class << res
        attr_accessor :_uri, :_elapsed, :_proxy
        def _headers; each_header.inject({}) { |h, (k, v)| h[k] = v; h }; end
      end
      res._uri = uri.to_s
      res._elapsed = monow - t0
      #res._proxy = detail_proxy(http)

      fail "request returned a #{res.class} and not a Net::HTTPResponse" \
        unless res.is_a?(Net::HTTPResponse)

      res
    end

    def make_net_http(uri)

      http = Net::HTTP.new(uri.host, uri.port)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = ssl_verify_mode
      end

      http
    end
  end
end

