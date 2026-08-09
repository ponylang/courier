class val Origin is (Equatable[Origin] & Stringable)
  """
  The origin of a URL: whether it is secure (https), the host, and the port.

  Two requests share an origin when all three match. Host comparison is
  case-insensitive; the host is lowercased on construction. Redirect header
  stripping uses origin equality — credentials are removed when a hop crosses
  to a different origin.
  """
  let secure: Bool
  let host: String
  let port: String

  new val create(secure': Bool, host': String, port': String) =>
    secure = secure'
    host = host'.lower()
    port = port'

  new val _from_url(url: ParsedURL val) =>
    secure = url.is_ssl()
    host = url.host.lower()
    port = url.port

  fun eq(that: Origin box): Bool =>
    (secure == that.secure) and (host == that.host) and (port == that.port)

  fun string(): String iso^ =>
    recover
      String
        .> append(if secure then "https" else "http" end)
        .> append("://")
        .> append(host)
        .> append(":")
        .> append(port)
    end
