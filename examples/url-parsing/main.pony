use "../../courier"

actor Main
  new create(env: Env) =>
    let url_str = "https://httpbin.org/get?source=courier"
    match \exhaustive\ URL.parse(url_str)
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
    | let err: URLParseError =>
      let msg =
        match \exhaustive\ err
        | MissingScheme => "missing scheme"
        | UnsupportedScheme => "unsupported scheme"
        | MissingHost => "missing host"
        | InvalidPort => "invalid port"
        | UserInfoNotSupported => "userinfo not supported"
        end
      env.out.print("URL parse error: " + msg)
    end
