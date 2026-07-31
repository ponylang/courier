use lori = "lori"
use "pony_test"

class \nodoc\ iso _TestYieldReadOrdering is UnitTest
  """
  A `yield_read()` call from `on_body_chunk()` stops reading after the
  delivery it was called from, and only that one.

  Feeding the connection by hand is what makes the delivery boundary a fact
  rather than an assumption: the returned `ReadAction` is the answer for the
  delivery whose callback called `yield_read()`.
  """
  fun name(): String => "yield_read/stops_reading_after_its_delivery"

  fun apply(h: TestHelper) =>
    h.long_test(5_000_000_000)
    h.dispose_when_done(_TestYieldReadOrderingClient(h))

actor \nodoc\ _TestYieldReadOrderingClient is HTTPClientConnectionActor
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  let _h: TestHelper
  var _yielding: Bool = true
  var _chunks: USize = 0

  new create(h: TestHelper) =>
    _h = h
    // Nothing listens here. `HTTPClientConnection.create` builds the parser
    // before it touches the network, and it queues `_finish_initialization`,
    // so `drive` runs against a live parser whether or not the connect ever
    // completes.
    let host = ifdef linux then "127.0.0.2" else "localhost" end
    _http =
      HTTPClientConnection(
        lori.TCPConnectAuth(h.env.root),
        host,
        "45999",
        this,
        ClientConnectionConfig)
    drive()

  fun ref _http_client_connection(): HTTPClientConnection => _http

  be drive() =>
    let response = "HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"
    let first = _http._on_received(response.clone().iso_array())
    _h.assert_eq[USize](
      1,
      _chunks,
      "the response body never reached on_body_chunk()")
    _h.assert_is[lori.ReadAction](
      lori.YieldReading,
      first,
      "yield_read() from on_body_chunk did not stop reading after the "
        + "data it was called from")

    _yielding = false
    let second = _http._on_received(response.clone().iso_array())
    _h.assert_is[lori.ReadAction](
      lori.KeepReading,
      second,
      "reading stopped again on a delivery that never called yield_read()")

    _h.complete(true)
    _http.close()

  fun ref on_body_chunk(data: Array[U8] val) =>
    _chunks = _chunks + 1
    if _yielding then
      _http.yield_read()
    end

  fun ref on_connection_failure(reason: ConnectionFailureReason) =>
    // Expected — nothing is listening. The test drives the parser directly.
    None
