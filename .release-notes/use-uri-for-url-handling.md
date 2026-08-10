## Switch URL handling to ponylang/uri

Courier no longer has its own URL parsing layer. `URL`, `ParsedURL`, `Scheme`, `SchemeHTTP`, `SchemeHTTPS`, and `URLParseError` (with its variants `MissingScheme`, `UnsupportedScheme`, `MissingHost`, `InvalidPort`, `UserInfoNotSupported`) are removed. Use `uri.ParseURI` and `uri.URI` from the [ponylang/uri](https://github.com/ponylang/uri) package instead.

`Redirect.target()` now returns `uri.URI val` instead of `ParsedURL val`, and `RedirectConnectionFactory.apply()` takes `uri.URI val` instead of `ParsedURL val`. Code that constructs a connection in a redirect factory can use `Origin.from_uri()` to extract host, port, and scheme from the target URI.

Before:

```pony
let factory =
  {ref(target: ParsedURL val)
    (auth, ssl_ctx, config, client = this)
    : HTTPClientConnection
  =>
    if target.is_ssl() then
      HTTPClientConnection.ssl(
        auth, ssl_ctx, target.host, target.port, client, config)
    else
      HTTPClientConnection(
        auth, target.host, target.port, client, config)
    end
  }
```

After:

```pony
let factory =
  {ref(target: uri.URI val)
    (auth, ssl_ctx, config, client = this)
    : HTTPClientConnection
  =>
    let o = Origin.from_uri(target)
    if o.host.size() == 0 then
      return HTTPClientConnection.none()
    end
    if o.secure then
      HTTPClientConnection.ssl(
        auth, ssl_ctx, o.host, o.port, client, config)
    else
      HTTPClientConnection(
        auth, o.host, o.port, client, config)
    end
  }
```
