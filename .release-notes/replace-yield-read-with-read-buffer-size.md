## Replace yield_read() with a settable read buffer size

`HTTPClientConnection.yield_read()` has been removed. It could not limit how much work a connection does per scheduler turn — lori's read buffer size is what controls that, and courier was not exposing it.

`ClientConnectionConfig` now takes a `read_buffer_size` parameter (defaults to 16 KB, lori's default). A smaller buffer means less data read per turn; a larger one means fewer turns to deliver a big response.

Before:

```pony
fun ref on_body_chunk(data: Array[U8] val) =>
  _http.yield_read()
```

After:

```pony
let rbs = match lori.MakeReadBufferSize(4096)
| let r: lori.ReadBufferSize => r
end
ClientConnectionConfig(where read_buffer_size' = rbs)
```
