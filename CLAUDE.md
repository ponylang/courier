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
- [json-ng](https://github.com/ponylang/json-ng) 0.3.0 — JSON parsing (for `ResponseJson`)

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

### Layer: Convenience Utilities (PR 2)

**Response collector:**
- `HTTPResponse` — `class val` with version, status, reason, headers, and complete body as `Array[U8] val`
- `ResponseCollector` — `class ref` that accumulates `on_response()` + `on_body_chunk()` callbacks, then `build()` produces `HTTPResponse val`. Partial: errors if `set_response()` was never called. Create a fresh collector per request/response cycle.

**Request builder:**
- `Request` — primitive factory with `get()`, `head()`, `post()`, `put()`, `patch()`, `delete()`, `options()`
- `RequestOptions` — interface for all methods: `header()`, `query()`, `basic_auth()`, `bearer_auth()`, `build()`
- `RequestOptionsWithBody` — extends with `body()`, `json_body()`, `form_body()`; narrows to `RequestOptions` after body is set
- `_RequestBuilder` — internal class implementing both interfaces
- GET/HEAD return `RequestOptions` (no body). DELETE/OPTIONS/POST/PUT/PATCH return `RequestOptionsWithBody`.
- CONNECT and TRACE omitted from builder (use `HTTPRequest(CONNECT, ...)` directly)

**Encoding utilities:**
- `QueryParams` — primitive, encodes `Array[(String, String)] val` as RFC 3986 query string (returns `String`)
- `FormEncoder` — primitive, encodes as `application/x-www-form-urlencoded` per WHATWG (returns `Array[U8] val`)
- `_PercentEncoder` — internal primitive with `query()` (RFC 3986) and `form()` (WHATWG) encoding modes

**Auth helpers:**
- `BasicAuth` — primitive, returns `("authorization", "Basic <base64>")` tuple
- `BearerAuth` — primitive, returns `("authorization", "Bearer <token>")` tuple

**JSON utilities:**
- `ResponseJson` — primitive, parses `HTTPResponse.body` as JSON via json-ng, returns `(JsonValue | JsonParseError)`
- `JsonDecodeError` — `class val ... is Stringable`, structural mismatch when decoding parsed JSON (wrong field types, missing fields)
- `JsonDecoder[A]` — `interface val`, converts `JsonValue` into typed domain object `A` or `JsonDecodeError`
- `DecodeJson[A]` — primitive, combines `ResponseJson` + `JsonDecoder` into single call, returns `(A | JsonParseError | JsonDecodeError)`

### Key Design Decisions

- `send_request()` returns explicit `SendRequestResult`, not fire-and-forget
- Only one request in flight at a time (`_Idle`/`_AwaitingResponse` state)
- User-initiated close does NOT complete in-progress close-delimited responses
- Remote close DOES complete close-delimited responses (natural end signal)
- `_on_tls_ready`/`_on_tls_failure` inherited as no-ops — lori routes initial SSL through `_on_connected`/`_on_connection_failure`
- `QueryParams` returns `String` (for URL paths), `FormEncoder` returns `Array[U8] val` (for request body) — deliberate asymmetry matching their usage context
- Request builder uses structural subtyping: `_RequestBuilder` satisfies both `RequestOptions` and `RequestOptionsWithBody` interfaces. Factory methods return the appropriate interface type to enforce compile-time body restriction.

## Release Notes

Follow the standard ponylang release notes conventions. Create individual `.md` files in `.release-notes/` for each PR with user-facing changes.
