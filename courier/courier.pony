"""
courier — HTTP client for Pony.

Courier is an HTTP/1.1 client library built on
[lori](https://github.com/ponylang/lori). It follows the same architectural
pattern as lori and [stallion](https://github.com/ponylang/stallion): a
protocol handler class (`HTTPClientConnection`) owned by the user's actor,
with synchronous `fun ref` callbacks. No hidden actors.

## Getting Started

Implement `HTTPClientConnectionActor` on your actor, store an
`HTTPClientConnection` as a field, and override the lifecycle callbacks
you need:

```pony
use "courier"
use lori = "lori"

actor MyClient is HTTPClientConnectionActor
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  let _out: OutStream

  new create(auth: lori.TCPConnectAuth, host: String, port: String,
    out: OutStream)
  =>
    _out = out
    _http = HTTPClientConnection(auth, host, port, this,
      ClientConnectionConfig)

  fun ref _http_client_connection(): HTTPClientConnection => _http

  fun ref on_connected() =>
    _http.send_request(HTTPRequest(GET, "/"))

  fun ref on_response(response: Response val) =>
    _out.print(response.status.string() + " " + response.reason)

  fun ref on_body_chunk(data: Array[U8] val) =>
    _out.write(data)

  fun ref on_response_complete() =>
    _out.print("")
    _http.close()
```

For HTTPS, use `HTTPClientConnection.ssl()` instead of
`HTTPClientConnection()`.

## Key Types

- `HTTPClientConnectionActor` — trait for your actor
- `HTTPClientConnection` — protocol handler class (stored as actor field)
- `HTTPClientLifecycleEventReceiver` — callback trait (default no-ops)
- `HTTPRequest` — request data (method, path, headers, body)
- `Response` — parsed response metadata (version, status, reason, headers)
- `ClientConnectionConfig` — parser limits, idle timeout, bind address
- `SendRequestResult` — result of `send_request()` (success or error)
- `HTTPResponse` — buffered response with complete body (from `ResponseCollector`)
- `ResponseCollector` — accumulates streaming callbacks into `HTTPResponse`
- `QueryParams` — RFC 3986 query string encoding
- `FormEncoder` — `application/x-www-form-urlencoded` body encoding
- `BasicAuth` — HTTP Basic authentication header
- `BearerAuth` — HTTP Bearer token authentication header
- `Request` — factory for typed step-builder request construction
- `RequestOptions` — builder interface for all methods (headers, query, auth)
- `RequestOptionsWithBody` — builder interface with body methods (POST, etc.)
- `ResponseJson` — parse `HTTPResponse` body as JSON via json-ng
- `JsonDecoder` — interface for typed JSON decoders
- `JsonDecodeError` — decode failure with descriptive message
- `DecodeJson` — parse and decode an HTTP response body in one step

## Design

See [Discussion #2](https://github.com/ponylang/courier/discussions/2) for
the full design rationale.
"""
