
#
# Specifying scorn
#
# Tue Jan  5 11:06:04 JST 2021
#

require 'spec_helper'


describe Scorn do

  describe '.get' do

    it 'gets' do

      r = Scorn.get('https://reqbin.com')

      expect(r).to match(/<script>/)
      expect(r._response.code).to eq('200')
      expect(r._response._c).to eq(200)
      expect(r._response._sta).to eq('OK')
    end

    it 'gets JSON' do

      r = Scorn.get('https://httpbin.org/get', json: true)

      expect(r['args']).to eq({})
      expect(r['headers']['Host']).to eq('httpbin.org')
      expect(r['headers']['Accept']).to eq('application/json')
      expect(r['url']).to eq('https://httpbin.org/get')
    end

    it 'returns a String but with a _response' do

      r = Scorn.get('https://reqbin.com')

      expect(r._response.code
        ).to eq('200')
      expect(r._response._headers['content-type']
        ).to eq('text/html; charset=utf-8')
    end

    it 'gets 404' do

      r = Scorn.get('https://httpbin.org/status/404')

      expect(r).to eq('')
      expect(r._response._c). to eq(404)
      expect(r._response._sta). to eq('Not Found')
    end
  end

  describe '.post' do

    it 'posts application/x-www-form-urlencoded by default' do

      r = Scorn.post(
        'https://httpbin.org/post',
        data: { source: 'src', target: 'tgt', n: -1 })

      expect(r['args']).to eq({})
      expect(r['data']).to eq('')
      expect(r['files']).to eq({})
      expect(r['form']).to eq('n' => '-1', 'source' => 'src', 'target' => 'tgt')
      expect(r['json']).to eq(nil)

      expect(r['url']).to eq('https://httpbin.org/post')

      expect(r['headers']['Content-Type']
        ).to eq('application/x-www-form-urlencoded')

      expect(r._response.code).to eq('200')
      expect(r._response._c).to eq(200)
      expect(r._response._sta).to eq('OK')
    end
  end
end

