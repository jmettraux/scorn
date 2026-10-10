
# scorn

<!--[![tests](https://github.com/jmettraux/scorn/workflows/test/badge.svg)](https://github.com/jmettraux/scorn/actions)-->
[![gem version](https://badge.fury.io/rb/scorn.svg)](http://badge.fury.io/rb/scorn)

A stupid HTTP client library.

```ruby
r = Scorn.get('https://example.com/data.json')

p r # => { "data" => [ "foo", "bar" ] }
p r._response._c # => 200
```

```ruby
r = Scorn.get('https://httpbin.org/get', json: true)

p r._response._c # => 200
p r['args'] # => {}
p r['headers']['Host'] # => 'httpbin.org'
p r['headers']['Accept'] # => 'application/json'
p r['url'] # => 'https://httpbin.org/get'
```

```ruby
r = Scorn.post(
  'https://httpbin.org/post',
  data: { source: 'src', target: 'tgt', n: -1 },
  debug: $stderr)

p r._response._c # => 200
p r._response._sta # => 'OK'
p r._response.code # => '200'

p r.class # => Hash
p r['form'] # => { 'n' => '-1', 'source' => 'src', 'target' => 'tgt' }
```


### Options:

* `accept:` for the `Accept` header
* `uauthorization:` or `auth:` for the `Authorization` header
* `content_type:` for the `Content-Type` header
* `etag:` or `if_none_match:` for the `If-None-Match` header
* `user_agent:` for the `Agent` header
* `ssl_verify: false`, `ssl_verify: :none`, `verify: false`, as expected

```ruby
r = Scorn.get(
  'https://httpbin.org/get',
  auth: 'Bearer toto-nada-xplus',
  json: true)

p r['headers']['Authorization'] # => 'Bearer toto-nada-xplus'
```


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

