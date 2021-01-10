
# scorn

A stupid HTTP client library.

```ruby
r = Scorn.get('https://example.com/data.json')

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


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

