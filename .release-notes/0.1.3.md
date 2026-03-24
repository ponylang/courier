## Expose one-shot timer API

One-shot timers are now available on `HTTPClientConnection` for response deadlines and application-level timeouts.

Call `set_timer()` with a duration to start a timer, and override `on_timer()` to handle it when it fires. Cancel with `cancel_timer()` if you no longer need it. Only one timer can be active per connection at a time.

Unlike idle timeout, this timer fires unconditionally — I/O activity does not reset it. The typical use is a response deadline: set a timer after sending a request, cancel it when the response arrives, close the connection if the deadline fires first:

```pony
fun ref on_connected() =>
  _http.send_request(Request.get("/").build())
  match lori.MakeTimerDuration(5_000)
  | let d: lori.TimerDuration =>
    match _http.set_timer(d)
    | let t: lori.TimerToken => _timer = t
    | let err: lori.SetTimerError => None
    end
  end

fun ref on_response_complete() =>
  match _timer
  | let t: lori.TimerToken =>
    _http.cancel_timer(t)
    _timer = None
  end
  _http.close()

fun ref on_timer(token: lori.TimerToken) =>
  _out.print("Response timed out")
  _http.close()
```

