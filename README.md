# courier

An HTTP/1.1 client for Pony.

## Status

courier is beta quality software that will change frequently. Expect breaking changes. That said, you should feel comfortable using it in your projects.

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/ponylang/courier.git --version 0.1.2`
* `corral fetch` to fetch your dependencies
* `use "courier"` to include this package
* `corral run -- ponyc` to compile your application

You'll also need an SSL library installed on your platform. See the [ssl](https://github.com/ponylang/ssl) package for details.

## Usage

```pony
use "courier"
use lori = "lori"

actor Main
  new create(env: Env) =>
    let auth = lori.TCPConnectAuth(env.root)
    BasicClient(auth, "example.com", "80", env.out)

actor BasicClient is HTTPClientConnectionActor
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  var _collector: ResponseCollector = ResponseCollector
  let _out: OutStream

  new create(
    auth: lori.TCPConnectAuth,
    host: String,
    port: String,
    out: OutStream)
  =>
    _out = out
    _http = HTTPClientConnection(auth, host, port, this,
      ClientConnectionConfig)

  fun ref _http_client_connection(): HTTPClientConnection => _http

  fun ref on_connected() =>
    _http.send_request(Request.get("/").build())

  fun ref on_response(response: Response val) =>
    _collector = ResponseCollector
    _collector.set_response(response)

  fun ref on_body_chunk(data: Array[U8] val) =>
    _collector.add_chunk(data)

  fun ref on_response_complete() =>
    try
      let response = _collector.build()?
      _out.print(String.from_array(response.body))
    end
    _http.close()

  fun ref on_closed() =>
    _out.print("Connection closed")
```

See the [examples](examples/) directory for more.

## API Documentation

[https://ponylang.github.io/courier](https://ponylang.github.io/courier)
