use "../../courier"
use lori = "lori"

actor Main
  new create(env: Env) =>
    let auth = lori.TCPConnectAuth(env.root)
    BasicClient(auth, "example.com", "80", env.out)

actor BasicClient is HTTPClientConnectionActor
  """
  Simple HTTP client that sends a GET request and prints the response.

  Usage: ./basic
  Connects to example.com:80, sends GET /, prints status and body.
  Requires network access. The program exits after receiving the response.
  """
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  let _out: OutStream

  new create(
    auth: lori.TCPConnectAuth,
    host: String,
    port: String,
    out: OutStream)
  =>
    _out = out
    _http = HTTPClientConnection(auth, host, port, this,
      ClientConnectionConfig)

  fun ref _http_client_connection(): HTTPClientConnection => _http

  fun ref on_connected() =>
    _http.send_request(HTTPRequest(GET, "/"))

  fun ref on_connection_failure() =>
    _out.print("Connection failed")

  fun ref on_response(response: Response val) =>
    _out.print("< " + response.version.string() + " "
      + response.status.string() + " " + response.reason)
    for (name, value) in response.headers.values() do
      _out.print("< " + name + ": " + value)
    end
    _out.print("")

  fun ref on_body_chunk(data: Array[U8] val) =>
    _out.write(data)

  fun ref on_response_complete() =>
    _out.print("")
    _http.close()

  fun ref on_closed() =>
    _out.print("Connection closed")
