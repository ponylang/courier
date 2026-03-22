## Update ponylang/ssl to 2.0.1

Updates the ponylang/ssl dependency to 2.0.1 to pick up a bug fix.

## Add connection timeout support

You can now set a connection timeout that bounds how long the TCP (and TLS) handshake phase is allowed to take. If the timeout fires before the connection is ready, `on_connection_failure` is called with the new `ConnectionFailedTimeout` reason.

Configure it through `ClientConnectionConfig`:

```pony
let ct = match lori.MakeConnectionTimeout(5_000)
| let t: lori.ConnectionTimeout => t
end
ClientConnectionConfig(where connection_timeout' = ct)
```

The default is `None` (no timeout), which preserves existing behavior.

If you have an exhaustive match on `ConnectionFailureReason`, you'll need to add a case for `ConnectionFailedTimeout`:

```pony
// Before
match \exhaustive\ reason
| ConnectionFailedDNS => "DNS failed"
| ConnectionFailedTCP => "TCP failed"
| ConnectionFailedSSL => "SSL failed"
end

// After
match \exhaustive\ reason
| ConnectionFailedDNS => "DNS failed"
| ConnectionFailedTCP => "TCP failed"
| ConnectionFailedSSL => "SSL failed"
| ConnectionFailedTimeout => "Connection timed out"
end
```

## Fix SSL connection idle timeout issues

Idle timeouts didn't fire reliably on SSL connections. This could cause HTTPS connections to stay open longer than expected when using `idle_timeout` in `ClientConnectionConfig`.

## Fix connection resource leak on early close

Closing a connection while it was still being established could leak internal connection resources.

