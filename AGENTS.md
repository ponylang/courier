# HTTP Client for Pony

<!-- contributor-only -->
## Contributing with an AI assistant

This is a Pony project. The ponylang org maintains a set of LLM coding skills. Get set up with them before contributing:

- **Not set up yet?** Install them once:

  ```bash
  git clone https://github.com/ponylang/llm-skills.git
  cd llm-skills
  python install.py
  ```

- **Already set up?** Make sure you're on the latest. If you installed with the script above, `git pull` in the directory where you cloned `llm-skills` and the symlinked skills update automatically — if you set them up another way, refresh them however that setup expects.

See the [llm-skills README](https://github.com/ponylang/llm-skills) for details and other harnesses.

When you start working on this project, load the `pony-skills` skill — it tells your assistant which Pony skill to use for each task.

Read [CONTRIBUTING.md](CONTRIBUTING.md).
<!-- /contributor-only -->

## Building

```
make ssl=3.0.x      # build and run tests (OpenSSL 3.x)
make ssl=1.1.x      # build and run tests (OpenSSL 1.1.x)
make test-one t=TestName ssl=3.0.x  # run a single test by name
make ssl=libressl   # build and run tests (LibreSSL)
make clean           # clean build artifacts
```

The `ssl` option is required because this library depends on the `ssl` package via lori.

## Dependencies

- [lori](https://github.com/ponylang/lori) 0.16.0 — TCP I/O with connection-actor model
- [ssl](https://github.com/ponylang/ssl) 2.0.1 — SSL/TLS support

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
