
require 'json'
require 'time'
require 'base64'
require 'webrick' # for the http code to message mapping
require 'ostruct'
require 'openssl'
require 'net/http'


module Scorn

  VERSION = '0.4.0'

  class << self

    def head(uri, opts={})

      Scorn::Client.new(opts).head(uri, opts)
    end

    def get(uri, opts={})

      Scorn::Client.new(opts).get(uri, opts)
    end

    def post(uri, opts)

      Scorn::Client.new(opts).post(uri, opts)
    end
  end

  class Client

    attr_accessor :user_agent, :ssl_verify_mode

    def initialize(opts)

      @opts = opts

      @user_agent =
        opts[:user_agent] ||
        "scorn #{VERSION} - " +
        [ 'Ruby', RUBY_VERSION, RUBY_RELEASE_DATE, RUBY_PLATFORM ].join(' ')

      @ssl_verify_mode =
        (
          opts[:ssl_verify] == :none || opts[:verify] == :none ||
          opts[:ssl_verify] == false || opts[:verify] == false
        ) ?
        OpenSSL::SSL::VERIFY_NONE : # :-(
        OpenSSL::SSL::VERIFY_PEER
    end

    def head(uri, opts={})

      u = uri.is_a?(String) ? URI(uri) : uri

      res = request(u, make_head_req(u, opts))

      opts[:res] ? res : read_response(res)
    end

    def get(uri, opts={})

      u = uri.is_a?(String) ? URI(uri) : uri

      res = request(u, make_get_req(u, opts))

      opts[:res] ? res : read_response(res)
    end

    def post(uri, opts)

      u = uri.is_a?(String) ? URI(uri) : uri

      res = request(u, make_post_req(u, opts))

      opts[:res] ? res : read_response(res)
    end

    protected

    def make_head_req(uri, opts)

      make_req(:head, uri, gather_headers(:head, opts))
    end

    def make_get_req(uri, opts)

      make_req(:get, uri, gather_headers(:get, opts))
    end

    def make_post_req(uri, opts)

      req = make_req(:post, uri, gather_headers(:post, opts))

      data = opts[:data]
      req.set_form_data(data) if data

      req
    end

    def gather_headers(verb, opts)

      h = {}

      h['Accept'] =
        opts[:accept] ||
        (opts[:json] && 'application/json') ||
        '*/*'
      h['Agent'] =
        opts[:user_agent] || user_agent
      h['Authorization'] =
        opts[:authorization] || opts[:auth]

      h['Content-Type'] =
        opts[:content_type] || 'application/x-www-form-urlencoded' \
          if verb == :post

      opts.each do |k, v|
        h[k] = v if k.start_with?(/X-/)
      end

      h.compact!

      h
    end

    def make_req(type, uri, headers)

      u = [ uri.path, uri.query ].compact.join('?')
      u = '/' if u.length < 1

      req =
        case type
        when :head then Net::HTTP::Head.new(u)
        when :get then Net::HTTP::Get.new(u)
        when :post then Net::HTTP::Post.new(u)
        else fail ArgumentError.new("HTTP #{type} not implemented")
        end

      headers.each { |k, v| req[k] = v }

      req
    end

    def monow; Process.clock_gettime(Process::CLOCK_MONOTONIC); end

    def request(uri, req)

      t0 = monow

      http = make_net_http(uri)

      res = http.request(req)

      class << res
        attr_accessor :_u, :_uri, :_request, :_c, :_sta, :_elapsed, :_proxy
        def _headers; each_header.inject({}) { |h, (k, v)| h[k] = v; h }; end
      end
      res._u = uri.to_s
      res._uri = uri
      res._request = req
      res._c = res.code.to_i
      res._sta = WEBrick::HTTPStatus.reason_phrase(res.code) rescue ''
      res._elapsed = monow - t0
      #res._proxy = detail_proxy(http)

      fail "request returned a #{res.class} and not a Net::HTTPResponse" \
        unless res.is_a?(Net::HTTPResponse)

      res
    end

    def make_net_http(uri)

      http = Net::HTTP.new(uri.host, uri.port)

      http.set_debug_output(@opts[:debug])
      #http.set_debug_output($stderr)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = ssl_verify_mode
      end

      http
    end

    def read_response(res)

      s = res.body
      st = s ? s.strip : ''

      a_z = "#{st[0, 1]}#{st[-1, 1]}"

      r =
        if a_z == '{}' || a_z == '[]'
          JSON.parse(st) rescue s
        elsif s == nil
          ''
        else
          s
        end
      class << r; attr_accessor :_response; end
      r._response = res

      r
    end
  end
end

