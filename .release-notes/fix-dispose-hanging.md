## Fix dispose() hanging when peer FIN is missed

`HTTPClientConnectionActor.dispose()` could hang indefinitely on POSIX systems when the peer's FIN notification was missed in a narrow timing window. The connection would get stuck in CLOSE_WAIT, preventing the Pony runtime from exiting. Disposal now performs an unconditional hard close, matching what callers expect: immediate teardown without waiting for a protocol exchange.
