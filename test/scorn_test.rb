
#
# Specifying scorn
#
# Tue Jan  5 11:06:04 JST 2021
#


group Scorn do

  before do

    sleep 0.7
      # so that reqbin.com isn't overwhelmed
  end

  group '.head' do

    test 'heads' do

      r = Scorn.head('https://reqbin.com')

      assert r, ''
      assert r._response.code, '200'
      assert r._response._c, 200
      assert r._response._sta, 'OK'
    end
  end

  group '.get' do

    test 'gets' do

      r = Scorn.get('https://reqbin.com')

      assert r, /<script>/
      assert r._response.code, '200'
      assert r._response._c, 200
      assert r._response._sta, 'OK'
    end

    test 'gets JSON' do

      r = Scorn.get('https://httpbin.org/get', json: true)

      #assert r['args'], {}
      assert r['headers']['Host'], 'httpbin.org'
      assert r['headers']['Accept'], 'application/json'
      assert r['url'], 'https://httpbin.org/get'
    end

    test 'returns a String but with a _response' do

      r = Scorn.get('https://reqbin.com')

      assert r._response.code, '200'
      assert r._response._headers['content-type'], 'text/html; charset=utf-8'
    end

    test 'gets 404' do

      r = Scorn.get('https://httpbin.org/status/404')

      assert r, ''
      assert r._response._c, 404
      assert r._response._sta, 'Not Found'
    end
  end

  group '.post' do

    test 'posts application/x-www-form-urlencoded by default' do

      r = Scorn.post(
        'https://httpbin.org/post',
        data: { source: 'src', target: 'tgt', n: -1 })

      assert r['args'], {}
      assert r['data'], ''
      assert r['files'], {}
      assert r['form'], { 'n' => '-1', 'source' => 'src', 'target' => 'tgt' }
      assert r['json'], nil

      assert r['url'], 'https://httpbin.org/post'

      assert r['headers']['Content-Type'], 'application/x-www-form-urlencoded'

      assert r._response.code, '200'
      assert r._response._c, 200
      assert r._response._sta, 'OK'
    end

    test 'posts without doubling the Content-Type header' do

      d = RequestDebugger.new

      r = Scorn.post(
        'https://httpbin.org/post',
        data: { source: 'src', n: 11 },
        debug: d)

      assert r['form'], { 'n' => '11', 'source' => 'src' }

#pp d.request_headers
      assert d.request_headers.count { |k, v| k == 'Content-Type' }, 1
    end
  end
end

