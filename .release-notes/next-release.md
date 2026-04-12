
## Fix potential connection hang when timer event subscription fails

On some platforms, if the operating system cannot allocate resources for a connection timer (e.g., ENOMEM on kqueue or epoll), connections could hang silently instead of reporting an error. Timer subscription failures are now detected and reported as connection failures.

## Add ConnectionFailedTimerError to ConnectionFailureReason

`ConnectionFailureReason` now includes `ConnectionFailedTimerError`, which is reported when the connect timer's ASIO event subscription fails. If you match exhaustively on `ConnectionFailureReason`, you'll need to add a handler for the new variant:

```pony
match reason
| ConnectionFailedDNS => ...
| ConnectionFailedTCP => ...
| ConnectionFailedSSL => ...
| ConnectionFailedTimeout => ...
| ConnectionFailedTimerError => ...
end
```

## Require ponyc 0.63.1 or later

courier now requires ponyc 0.63.1 or later. Older ponyc versions are no longer supported.
