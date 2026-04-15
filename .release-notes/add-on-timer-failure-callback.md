## Add on_timer_failure callback

`HTTPClientLifecycleEventReceiver` has a new `on_timer_failure()` callback. It fires when a user timer created by `HTTPClientConnection.set_timer()` cannot be armed because its ASIO event subscription failed — typically from a kernel resource error like `ENOMEM` on `kevent` or `epoll_ctl`. Previously, the timer was silently cancelled and applications had no way to learn it had failed.

Before the callback fires, the timer has already been cancelled and its token cleared. The connection itself continues running. The application decides how to recover — call `set_timer()` again to try a new timer, close the connection, or take some other action.

```pony
actor MyClient is HTTPClientConnectionActor
  // ...

  fun ref on_timer_failure() =>
    // The query timer never armed. Give up on this request.
    _http.close()
```

The callback has a default no-op implementation, so existing receivers keep the silent-cancel behavior until they override it.
