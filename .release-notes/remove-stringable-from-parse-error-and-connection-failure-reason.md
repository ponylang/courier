## Remove Stringable from error types

`ParseError`, `ConnectionFailureReason`, and `URLParseError` primitives no longer implement `Stringable`. Users receive these through callbacks and can match on the concrete primitive to produce whatever string they want.

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
