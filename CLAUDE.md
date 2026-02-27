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

- [lori](https://github.com/ponylang/lori) 0.8.5 — TCP I/O with connection-actor model
- [ssl](https://github.com/ponylang/ssl) 2.0.0 — SSL/TLS support

## Package

Package: `courier` (repo name is `courier`, Pony package name is `courier`)

## Architecture

### Layer: Core Protocol (PR 1)

Courier follows the same pattern as lori and stallion: protocol handler class owned by the user's actor, with synchronous `fun ref` callbacks.

**Connection layer:**
- `HTTPClientConnection` — protocol handler class, implements `lori.ClientLifecycleEventReceiver` and `_ResponseParserNotify`. Stored as a field in the user's actor.
- `HTTPClientConnectionActor` — trait the user's actor implements (`lori.TCPConnectionActor & HTTPClientLifecycleEventReceiver`)
- `HTTPClientLifecycleEventReceiver` — callback trait with default no-ops: `on_connected`, `on_connection_failure`, `on_response`, `on_body_chunk`, `on_response_complete`, `on_parse_error`, `on_closed`, `on_throttled`, `on_unthrottled`
- `ClientConnectionConfig` — parser size limits, idle timeout, local bind address
- `_ConnectionState` — two-state trait (`_Active`/`_Closed`) routing lori events

**Request/Response types:**
- `HTTPRequest` — `class val` with method, path, headers, optional body
- `Response` — `class val` with version, status, reason, headers (delivered via `on_response()`)
- `SendRequestResult` — `(SendRequestOK | ConnectionClosed | ResponsePending)`
- `Method` — interface + 9 primitives (GET through PATCH) + `Methods` parser
- `Headers` — case-insensitive header collection (set/add/get/size/values)
- `Version` — `HTTP10 | HTTP11`
- `ParseError` — union of error primitives (TooLarge, InvalidStatusLine, etc.)

**Response parser (internal):**
- `_ResponseParser` — class, feeds data in chunks, delivers via `_ResponseParserNotify`
- `_ParserState` — trait-based state machine: `_ExpectStatusLine`, `_ExpectHeaders`, `_ExpectFixedBody`, `_ExpectChunkHeader`, `_ExpectChunkData`, `_ExpectChunkTrailer`, `_ExpectCloseDelimitedBody`
- 1xx informational responses are silently discarded
- HEAD, 204, 304 responses have no body regardless of headers
- Close-delimited body: no CL/chunked → body ends when connection closes (`connection_closed()`)

**Request serializer (internal):**
- `_RequestSerializer` — auto-sets Host and Content-Length if not present

### Key Design Decisions

- `send_request()` returns explicit `SendRequestResult`, not fire-and-forget
- Only one request in flight at a time (`_Idle`/`_AwaitingResponse` state)
- User-initiated close does NOT complete in-progress close-delimited responses
- Remote close DOES complete close-delimited responses (natural end signal)
- `_on_tls_ready`/`_on_tls_failure` inherited as no-ops — lori routes initial SSL through `_on_connected`/`_on_connection_failure`

## Release Notes

Follow the standard ponylang release notes conventions. Create individual `.md` files in `.release-notes/` for each PR with user-facing changes.
