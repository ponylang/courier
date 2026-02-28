use "../../courier"
use "files"
use json = "json"
use lori = "lori"
use ssl = "ssl/net"

actor Main
  new create(env: Env) =>
    let auth = lori.TCPConnectAuth(env.root)
    try
      let ssl_ctx = recover val
        let ctx = ssl.SSLContext
        ctx.set_client_verify(true)
        ctx.set_authority(
          FilePath(FileAuth(env.root), "/etc/ssl/certs/ca-certificates.crt"))?
        ctx
      end
      JsonApiClient(auth, ssl_ctx, env.out)
    else
      env.out.print("Failed to initialize SSL context")
    end

actor JsonApiClient is HTTPClientConnectionActor
  """
  JSON API client that fetches a JSON endpoint over HTTPS and parses it.

  Usage: ./json-api
  Connects to jsonplaceholder.typicode.com over HTTPS, fetches a todo item,
  parses the JSON response, and prints selected fields.

  Demonstrates `Request` builder for request construction, `ResponseCollector`
  for body accumulation, `ResponseJson` for JSON parsing, and
  `HTTPClientConnection.ssl()` for TLS connections.
  """
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  var _collector: ResponseCollector = ResponseCollector
  let _out: OutStream

  new create(
    auth: lori.TCPConnectAuth,
    ssl_ctx: ssl.SSLContext val,
    out: OutStream)
  =>
    _out = out
    _http = HTTPClientConnection.ssl(auth, ssl_ctx,
      "jsonplaceholder.typicode.com", "443", this, ClientConnectionConfig)

  fun ref _http_client_connection(): HTTPClientConnection => _http

  fun ref on_connected() =>
    let req = Request.get("/todos/1")
      .header("Accept", "application/json")
      .build()
    _http.send_request(req)

  fun ref on_connection_failure() =>
    _out.print("Connection failed")

  fun ref on_response(response: Response val) =>
    _collector = ResponseCollector
    _collector.set_response(response)
    _out.print("< " + response.status.string() + " " + response.reason)

  fun ref on_body_chunk(data: Array[U8] val) =>
    _collector.add_chunk(data)

  fun ref on_response_complete() =>
    try
      let response = _collector.build()?
      match ResponseJson(response)
      | let value: json.JsonValue =>
        match value
        | let obj: json.JsonObject =>
          _out.print("Todo item:")
          try
            match obj("title")?
            | let title: String =>
              _out.print("  title: " + title)
            end
          end
          try
            match obj("completed")?
            | let completed: Bool =>
              _out.print("  completed: " + completed.string())
            end
          end
        else
          _out.print("Unexpected JSON type")
        end
      | let err: json.JsonParseError =>
        _out.print("JSON parse error: " + err.string())
      end
    end
    _http.close()

  fun ref on_closed() =>
    _out.print("Connection closed")
