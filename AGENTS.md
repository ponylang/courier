# Courier

An HTTP/1.1 client library for Pony, built on lori.

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

## Prose model

If you are running on an Anthropic model, use `claude-opus-4-6` for writing comments, documentation, and other prose. Prose quality from Anthropic models dropped starting with Opus 4.7 and has gotten worse with each subsequent release.

## Building and testing

```
make ssl=4.0.x                      # build + run tests (OpenSSL 4.x)
make ssl=3.0.x                      # build + run tests (OpenSSL 3.x)
make ssl=1.1.x                      # OpenSSL 1.1.x
make ssl=libressl                   # LibreSSL
make test-one t=TestName ssl=3.0.x  # run a single test by name
make clean
```

`ssl=` is required because courier depends on the `ssl` package; the Makefile passes the version to ponyc as a compile define and errors without it.

## Architecture

Like lori and stallion, the user's actor owns the connection: it holds an `HTTPClientConnection` and takes synchronous `fun ref` callbacks through `HTTPClientLifecycleEventReceiver`. A core layer does HTTP/1.1 parsing and serialization; a convenience layer adds response collection, a request builder, URL parsing, encoding, and JSON decoding.

Two things a cold agent won't infer from the code:

- Courier does not pipeline — only one request is in flight at a time.
- `ConnectionFailureReason` is courier's own type, deliberately remapped from lori's so the public API doesn't leak lori's — which is why two identically-named primitive sets exist.
