## Fix a hang when closing a connection from a response callback

Calling `close()` from inside `on_response()`, `on_body_chunk()`, or `on_response_complete()` could leave the connection attempting one more read on the socket it had just closed. When many connections are opening and closing, that read could block one of the runtime's scheduler threads and keep the program from exiting. A connection closed from one of those callbacks no longer makes that read.

## Fix a connection stalling under sustained write backpressure

courier stops reading a connection while it is under write backpressure, from `on_throttled()` until `on_unthrottled()`. Under sustained backpressure with the server still sending, that pause could become permanent: data stopped moving in both directions and the connection never recovered on its own, staying wedged until it was closed. This was most likely on a multi-threaded runtime. A connection under sustained write backpressure no longer stalls.

## Fix backpressure not stopping incoming data on an HTTPS connection

On an HTTPS connection, backpressure did not stop response data arriving. When the socket backs up, courier stops reading the connection and `on_throttled()` fires; on HTTPS everything already decrypted from the same socket read was delivered anyway, so `on_response()`, `on_body_chunk()`, and `on_response_complete()` still fired after `on_throttled()`. Reading now stops as soon as backpressure is applied. Nothing is lost: data already decrypted is held rather than dropped, and it is delivered when backpressure clears, ahead of anything read off the socket afterwards.

## Fix yield_read() not taking effect on an HTTPS connection

`yield_read()` stops reading so other actors get a turn; call it from `on_body_chunk()` to keep one large response from starving the rest of your program. On an HTTPS connection it did not stop reading when you called it: everything already decrypted from the same socket read was handed to you first, so a long run of chunks could arrive before anything else ran. The yield now takes effect as soon as the parser finishes the data it was working on when you called it, on an HTTPS connection as on a plain HTTP one. It is still not immediate on either: every remaining chunk in that data fires `on_body_chunk()` before reading stops.

## Fix a hang when writing to a socket under load

Under write load, sending on a connection could hang the whole program. When the socket send buffer filled on a blocking file descriptor, the write stalled and never returned. Connections use non-blocking descriptors, so reaching this took the operating system reusing a closed connection's descriptor number for a blocking socket elsewhere in the same process — rare, but possible. The hang is closed on Linux, FreeBSD, OpenBSD, and DragonFly. macOS and Windows are unchanged.

## Require ponyc 0.67.0 or later

courier now requires ponyc 0.67.0 or later on every platform. The previous minimum was 0.64.0, and 0.66.0 on Windows; 0.64.0 through 0.66.x are no longer supported. The write hang under load is closed by a socket call that ponyc added in 0.67.0.

## Move to ponylang/ssl 3.0.0

courier now depends on ponylang/ssl 3.0.0, where it depended on 2.0.1. If your application does not declare ssl itself, it picks up 3.0.0 through courier, and your own `use "ssl/net"` or `use "ssl/crypto"` code is built against it. If your application does declare ssl, your declaration is the one that applies.

courier's own API is unchanged — an HTTPS connection still takes an `SSLContext val`. What can break is your own ssl code. The one you are most likely to hit is the rename of the protocol-version primitives, which now spell their acronyms in full, because setting a minimum TLS version on the context you hand courier is ordinary practice:

```pony
// Before
ctx.set_min_proto_version(Tls1u2Version())?

// After
ctx.set_min_proto_version(TLS1u2Version())?
```

All twelve protocol-version primitives were renamed the same way. ponylang/ssl 3.0.0 has other breaking changes too: constructing a `Digest`, `Digest.final`, and `HmacSha256` are now partial; `SSLContext.alpn_set_resolver` takes an `ALPNProtocolResolver val` where it took a `box`; `SSLState` gained an `SSLDisposed` member, which breaks an exhaustive match on `SSL.state()`; and a reference typed `HashFn tag` no longer compiles, so type it `val` or `box`. See ponylang/ssl's own 3.0.0 release notes for the full list.
