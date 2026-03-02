# HTTP Client for Pony

## Building

```
make ssl=3.0.x      # build and run tests (OpenSSL 3.x)
make ssl=1.1.x      # build and run tests (OpenSSL 1.1.x)
make ssl=libressl   # build and run tests (LibreSSL)
make clean           # clean build artifacts
```

The `ssl` option is required because this library depends on the `ssl` package via lori.

## Dependencies

- [lori](https://github.com/ponylang/lori) 0.9.0 — TCP I/O with connection-actor model
- [ssl](https://github.com/ponylang/ssl) 2.0.0 — SSL/TLS support
- [json-ng](https://github.com/ponylang/json-ng) 0.3.0 — JSON parsing (for `ResponseJSON`)

## Package

Package: `courier` (repo name is `courier`, Pony package name is `courier`)

## Architecture

Follows the lori/stallion pattern: protocol handler class (`HTTPClientConnection`) owned by the user's actor, with synchronous `fun ref` callbacks via `HTTPClientLifecycleEventReceiver`. Core protocol layer handles HTTP/1.1 parsing and serialization; convenience layer adds `ResponseCollector`, `Request` builder, URL parsing, encoding utilities, and JSON decoding.

Key things that would trip you up without prior knowledge:
- Only one request in flight at a time — `send_request()` returns `SendRequestResult` to signal this
- `ConnectionFailureReason` is courier's own type, not lori's — mapped internally to decouple the public API
- `QueryParams` returns `String` (for URL paths), `FormEncoder` returns `Array[U8] val` (for request body) — deliberate asymmetry
- User-initiated close does NOT complete close-delimited responses; remote close does
- `_on_tls_ready`/`_on_tls_failure` are inherited no-ops — lori routes SSL through `_on_connected`/`_on_connection_failure`

## Release Notes

Follow the standard ponylang release notes conventions. Create individual `.md` files in `.release-notes/` for each PR with user-facing changes.
