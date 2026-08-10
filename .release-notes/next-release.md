## Add opt-in redirect following

Courier can now follow HTTP redirects transparently. Redirect following is off by default — wrap an `HTTPClientConnection` in a `RedirectFollower` to opt in.

The follower sits in the callback path and handles redirect hops internally. The actor's response callbacks see only the final response; redirect responses and their bodies never reach user code. Same-origin redirects reuse the existing TCP connection. Cross-origin redirects use a `RedirectConnectionFactory` the actor provides to create a new one.

Security rules are applied before any hop: an `https`-to-`http` downgrade is refused, and on a cross-origin hop the `Authorization`, `Cookie`, `Proxy-Authorization`, `Host`, and `Referer` headers are stripped. A redirect that cannot be followed — too many hops, `Location` missing or unparseable, or an insecure downgrade — arrives at `on_redirect_error` on `RedirectFollowerNotify`.

## Remove Stringable from error types

`ParseError` and `ConnectionFailureReason` primitives no longer implement `Stringable`. Users receive these through callbacks and can match on the concrete primitive to produce whatever string they want.

Before:

```pony
fun ref on_connection_failure(reason: ConnectionFailureReason) =>
  _out.print("Connection failed: " + reason.string())
```

After:

```pony
fun ref on_connection_failure(reason: ConnectionFailureReason) =>
  let msg =
    match \exhaustive\ reason
    | ConnectionFailedDNS => "DNS resolution failed"
    | ConnectionFailedTCP => "TCP connection failed"
    | ConnectionFailedSSL => "SSL handshake failed"
    | ConnectionFailedTimeout => "connection timed out"
    | ConnectionFailedTimerError => "timer setup failed"
    end
  _out.print("Connection failed: " + msg)
```

## Replace yield_read() with a settable read buffer size

`HTTPClientConnection.yield_read()` has been removed. It could not limit how much work a connection does per scheduler turn — lori's read buffer size is what controls that, and courier was not exposing it.

`ClientConnectionConfig` now takes a `read_buffer_size` parameter (defaults to 16 KB, lori's default). A smaller buffer means less data read per turn; a larger one means fewer turns to deliver a big response.

Before:

```pony
fun ref on_body_chunk(data: Array[U8] val) =>
  _http.yield_read()
```

After:

```pony
let rbs = match lori.MakeReadBufferSize(4096)
| let r: lori.ReadBufferSize => r
end
ClientConnectionConfig(where read_buffer_size' = rbs)
```

## Fix on_closed firing twice when closing a backed-up connection

Closing a connection while the socket had backpressure applied delivered `on_closed()` to the application twice. A single `on_closed()` is now delivered regardless of socket state at close time.

