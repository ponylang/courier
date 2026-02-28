class val ParsedURL is Stringable
  """
  A parsed URL with scheme, host, port, path, and optional query string.

  Produced by `URL.parse()`. Fields are validated and normalized: the scheme
  is lowercase, the host has IPv6 brackets stripped, the port is a decimal
  string (defaulting to `"80"` for HTTP or `"443"` for HTTPS when omitted),
  and the path defaults to `"/"` when absent.

  Use `request_path()` to get the combined path and query string for the
  HTTP request target. Use `is_ssl()` to determine whether TLS is needed.
  """
  let scheme: Scheme
  let host: String
  let port: String
  let path: String
  let query: (String | None)

  new val _create(
    scheme': Scheme,
    host': String,
    port': String,
    path': String,
    query': (String | None))
  =>
    scheme = scheme'
    host = host'
    port = port'
    path = path'
    query = query'

  fun request_path(): String =>
    """
    The HTTP request target: path with query string appended if present.

    Always starts with `/`. For example, `/api/v1?key=value`.
    """
    match query
    | let q: String => path + "?" + q
    | None => path
    end

  fun is_ssl(): Bool =>
    """True if the scheme is HTTPS."""
    scheme is SchemeHTTPS

  fun string(): String iso^ =>
    """
    Reconstruct the URL as a string.

    Default ports (80 for HTTP, 443 for HTTPS) are omitted. IPv6 hosts are
    re-bracketed. The path is always included (at minimum `"/"`), so
    `http://example.com` round-trips as `http://example.com/`.
    """
    let s = recover iso String end
    s.append(scheme.string())
    s.append("://")

    // Re-bracket IPv6 addresses
    if host.contains(":") then
      s.push('[')
      s.append(host)
      s.push(']')
    else
      s.append(host)
    end

    // Include port only if non-default
    let default_port =
      if scheme is SchemeHTTP then "80" else "443" end
    if port != default_port then
      s.push(':')
      s.append(port)
    end

    s.append(path)

    match query
    | let q: String =>
      s.push('?')
      s.append(q)
    end

    consume s
