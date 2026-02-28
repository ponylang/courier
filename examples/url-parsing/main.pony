use "../../courier"
use "files"
use lori = "lori"
use ssl = "ssl/net"

actor Main
  new create(env: Env) =>
    let url_str = "https://httpbin.org/get?source=courier"
    match URL.parse(url_str)
    | let url: ParsedURL =>
      env.out.print("Parsed URL: " + url_str)
      env.out.print("  scheme: " + url.scheme.string())
      env.out.print("  host: " + url.host)
      env.out.print("  port: " + url.port)
      env.out.print("  path: " + url.path)
      match url.query
      | let q: String => env.out.print("  query: " + q)
      end
      env.out.print("  request_path: " + url.request_path())
      env.out.print("  is_ssl: " + url.is_ssl().string())

      let auth = lori.TCPConnectAuth(env.root)
      if url.is_ssl() then
        try
          let ssl_ctx = recover val
            let ctx = ssl.SSLContext
            ctx.set_client_verify(true)
            ctx.set_authority(
              FilePath(FileAuth(env.root),
                "/etc/ssl/certs/ca-certificates.crt"))?
            ctx
          end
          URLParsingClient.with_ssl(auth, ssl_ctx, url, env.out)
        else
          env.out.print("Failed to initialize SSL context")
        end
      else
        URLParsingClient(auth, url, env.out)
      end
    | let err: URLParseError =>
      env.out.print("URL parse error: " + err.string())
    end

actor URLParsingClient is HTTPClientConnectionActor
  """
  HTTP client that parses a URL and uses its components for the request.

  Usage: ./url-parsing
  Parses `https://httpbin.org/get?source=courier`, prints the parsed
  components, connects using the parsed host/port with TLS (based on
  `is_ssl()`), and sends a GET request using `request_path()`.
  httpbin.org echoes the request details back in a JSON response.

  Demonstrates `URL.parse()` for URL decomposition, `ParsedURL.is_ssl()` for
  choosing plain vs TLS connections, and `ParsedURL.request_path()` for the
  HTTP request target.
  """
  var _http: HTTPClientConnection = HTTPClientConnection.none()
  var _collector: ResponseCollector = ResponseCollector
  let _request_path: String
  let _out: OutStream

  new create(auth: lori.TCPConnectAuth, url: ParsedURL, out: OutStream) =>
    _request_path = url.request_path()
    _out = out
    _http = HTTPClientConnection(auth, url.host, url.port, this,
      ClientConnectionConfig)

  new with_ssl(
    auth: lori.TCPConnectAuth,
    ssl_ctx: ssl.SSLContext val,
    url: ParsedURL,
    out: OutStream)
  =>
    _request_path = url.request_path()
    _out = out
    _http = HTTPClientConnection.ssl(auth, ssl_ctx,
      url.host, url.port, this, ClientConnectionConfig)

  fun ref _http_client_connection(): HTTPClientConnection => _http

  fun ref on_connected() =>
    let req = Request.get(_request_path)
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
      _out.print(String.from_array(response.body))
    end
    _http.close()

  fun ref on_closed() =>
    _out.print("Connection closed")
