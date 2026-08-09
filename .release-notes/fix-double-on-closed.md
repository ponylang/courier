## Fix on_closed firing twice when closing a backed-up connection

Closing a connection while the socket had backpressure applied delivered `on_closed()` to the application twice. A single `on_closed()` is now delivered regardless of socket state at close time.
