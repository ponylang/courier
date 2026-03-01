use "pony_check"
use "pony_test"

// ---------------------------------------------------------------------------
// Property-based tests
// ---------------------------------------------------------------------------

class \nodoc\ iso _PropertyURLRoundtrip is Property1[_ValidURLParts]
  """
  A generated valid URL string parsed with URL.parse() produces field values
  matching the generated parts.
  """
  fun name(): String => "url/roundtrip"

  fun gen(): Generator[_ValidURLParts] =>
    _ValidURLPartsGen()

  fun ref property(arg1: _ValidURLParts, ph: PropertyHelper) =>
    let url_str = arg1.to_url_string()
    match \exhaustive\ URL.parse(url_str)
    | let parsed: ParsedURL =>
      ph.assert_eq[String val](
        arg1.scheme, parsed.scheme.string())
      ph.assert_eq[String val](arg1.host, parsed.host)
      if arg1.port != "" then
        ph.assert_eq[String val](arg1.port, parsed.port)
      end
      if arg1.path != "" then
        ph.assert_eq[String val](arg1.path, parsed.path)
      else
        ph.assert_eq[String val]("/", parsed.path)
      end
      if arg1.query != "" then
        match parsed.query
        | let q: String =>
          ph.assert_eq[String val](arg1.query, q)
        else
          ph.fail("expected query string")
        end
      else
        ph.assert_true(parsed.query is None)
      end
    | let err: URLParseError =>
      ph.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _PropertyURLDefaultPort is Property1[_ValidURLParts]
  """URLs without explicit port get the scheme default (80 or 443)."""
  fun name(): String => "url/default_port"

  fun gen(): Generator[_ValidURLParts] =>
    _ValidURLPartsGen()
      .filter({(parts: _ValidURLParts): (_ValidURLParts^, Bool) =>
        (parts, parts.port == "")
      })

  fun ref property(arg1: _ValidURLParts, ph: PropertyHelper) =>
    let url_str = arg1.to_url_string()
    match URL.parse(url_str)
    | let parsed: ParsedURL =>
      let expected =
        if parsed.scheme is SchemeHTTP then "80" else "443" end
      ph.assert_eq[String val](expected, parsed.port)
    | let err: URLParseError =>
      ph.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _PropertyURLRequestPathStartsWithSlash
  is Property1[_ValidURLParts]
  """request_path() always starts with /."""
  fun name(): String => "url/request_path_starts_with_slash"

  fun gen(): Generator[_ValidURLParts] =>
    _ValidURLPartsGen()

  fun ref property(arg1: _ValidURLParts, ph: PropertyHelper) =>
    let url_str = arg1.to_url_string()
    match URL.parse(url_str)
    | let parsed: ParsedURL =>
      let rp = parsed.request_path()
      ph.assert_true(
        rp.at("/"),
        "request_path should start with /: " + rp)
    | let err: URLParseError =>
      ph.fail("parse failed: " + err.string())
    end

// ---------------------------------------------------------------------------
// Test data generator
// ---------------------------------------------------------------------------
class val _ValidURLParts
  let scheme: String
  let host: String
  let port: String
  let path: String
  let query: String

  new val create(
    scheme': String,
    host': String,
    port': String,
    path': String,
    query': String)
  =>
    scheme = scheme'
    host = host'
    port = port'
    path = path'
    query = query'

  fun to_url_string(): String =>
    let s = recover iso String end
    s.append(scheme)
    s.append("://")
    s.append(host)
    if port != "" then
      s.push(':')
      s.append(port)
    end
    if path != "" then
      s.append(path)
    end
    if query != "" then
      s.push('?')
      s.append(query)
    end
    consume s

primitive \nodoc\ _ValidURLPartsGen
  fun apply(): Generator[_ValidURLParts] =>
    Generator[_ValidURLParts](
      object is GenObj[_ValidURLParts val]
        fun generate(rnd: Randomness): _ValidURLParts =>
          _ValidURLPartsGen._do_generate(rnd)
      end)

  fun _do_generate(rnd: Randomness): _ValidURLParts =>
    let scheme' = if rnd.bool() then "http" else "https" end
    let host' = _gen_host(rnd)
    let port' =
      if rnd.bool() then
        (rnd.u32(1, 65535)).string()
      else
        ""
      end
    let path' =
      if rnd.bool() then
        "/" + _gen_path_segment(rnd)
      else
        ""
      end
    let query' =
      if rnd.bool() then
        _gen_path_segment(rnd) + "=" + _gen_path_segment(rnd)
      else
        ""
      end
    _ValidURLParts(scheme', host', port', path', query')

  fun _gen_host(rnd: Randomness): String =>
    let len = rnd.usize(3, 12)
    let buf = recover iso String(len) end
    var i: USize = 0
    while i < len do
      buf.push(rnd.u8('a', 'z'))
      i = i + 1
    end
    buf.append(".com")
    consume buf

  fun _gen_path_segment(rnd: Randomness): String =>
    let len = rnd.usize(1, 10)
    let buf = recover iso String(len) end
    var i: USize = 0
    while i < len do
      buf.push(rnd.u8('a', 'z'))
      i = i + 1
    end
    consume buf

// ---------------------------------------------------------------------------
// Example-based tests
// ---------------------------------------------------------------------------
class \nodoc\ iso _TestURLFullComponents is UnitTest
  """Full URL with all components — verify fields, fragment discarded."""
  fun name(): String => "url/full_components"

  fun apply(h: TestHelper) =>
    match \exhaustive\
      URL.parse("https://example.com:8443/api/v1?key=value#section")
    | let u: ParsedURL =>
      h.assert_true(u.scheme is SchemeHTTPS)
      h.assert_eq[String val]("example.com", u.host)
      h.assert_eq[String val]("8443", u.port)
      h.assert_eq[String val]("/api/v1", u.path)
      match u.query
      | let q: String => h.assert_eq[String val]("key=value", q)
      else h.fail("expected query string")
      end
      h.assert_eq[String val]("/api/v1?key=value", u.request_path())
      h.assert_true(u.is_ssl())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLMinimal is UnitTest
  """Minimal URL with only scheme and host."""
  fun name(): String => "url/minimal"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com")
    | let u: ParsedURL =>
      h.assert_true(u.scheme is SchemeHTTP)
      h.assert_eq[String val]("example.com", u.host)
      h.assert_eq[String val]("80", u.port)
      h.assert_eq[String val]("/", u.path)
      h.assert_true(u.query is None)
      h.assert_false(u.is_ssl())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLDefaultPortHTTP is UnitTest
  """HTTP default port is 80."""
  fun name(): String => "url/default_port_http"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("80", u.port)
      h.assert_false(u.is_ssl())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLDefaultPortHTTPS is UnitTest
  """HTTPS default port is 443."""
  fun name(): String => "url/default_port_https"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("https://example.com/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("443", u.port)
      h.assert_true(u.is_ssl())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLMissingPathDefault is UnitTest
  """Missing path defaults to /."""
  fun name(): String => "url/missing_path_default"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com")
    | let u: ParsedURL =>
      h.assert_eq[String val]("/", u.path)
      h.assert_eq[String val]("/", u.request_path())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLFragmentDiscarded is UnitTest
  """Fragment is silently discarded."""
  fun name(): String => "url/fragment_discarded"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com/path#frag")
    | let u: ParsedURL =>
      h.assert_eq[String val]("/path", u.path)
      h.assert_true(u.query is None)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLIPv6Host is UnitTest
  """IPv6 host with brackets stripped."""
  fun name(): String => "url/ipv6_host"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://[::1]:8080/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("::1", u.host)
      h.assert_eq[String val]("8080", u.port)
      h.assert_eq[String val]("/path", u.path)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLIPv6DefaultPort is UnitTest
  """IPv6 host without explicit port gets scheme default."""
  fun name(): String => "url/ipv6_default_port"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://[::1]/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("::1", u.host)
      h.assert_eq[String val]("80", u.port)
      h.assert_eq[String val]("/path", u.path)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLCaseInsensitiveScheme is UnitTest
  """Scheme matching is case-insensitive."""
  fun name(): String => "url/case_insensitive_scheme"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("HTTP://example.com/path")
    | let u: ParsedURL =>
      h.assert_true(u.scheme is SchemeHTTP)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end
    match \exhaustive\ URL.parse("HtTpS://example.com/path")
    | let u: ParsedURL =>
      h.assert_true(u.scheme is SchemeHTTPS)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLEmptyPortDefault is UnitTest
  """Empty port after colon uses default port."""
  fun name(): String => "url/empty_port_default"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com:/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("80", u.port)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLErrorMissingScheme is UnitTest
  """URL without :// returns MissingScheme."""
  fun name(): String => "url/error_missing_scheme"

  fun apply(h: TestHelper) =>
    // No :// at all
    match \exhaustive\ URL.parse("example.com/path")
    | let _: ParsedURL => h.fail("expected MissingScheme")
    | let err: URLParseError =>
      h.assert_true(err is MissingScheme)
    end
    // Empty scheme before ://
    match \exhaustive\ URL.parse("://host/path")
    | let _: ParsedURL => h.fail("expected MissingScheme")
    | let err: URLParseError =>
      h.assert_true(err is MissingScheme)
    end

class \nodoc\ iso _TestURLErrorUnsupportedScheme is UnitTest
  """Unsupported scheme returns UnsupportedScheme."""
  fun name(): String => "url/error_unsupported_scheme"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("ftp://example.com/path")
    | let _: ParsedURL => h.fail("expected UnsupportedScheme")
    | let err: URLParseError =>
      h.assert_true(err is UnsupportedScheme)
    end

class \nodoc\ iso _TestURLErrorMissingHost is UnitTest
  """Empty host returns MissingHost."""
  fun name(): String => "url/error_missing_host"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http:///path")
    | let _: ParsedURL => h.fail("expected MissingHost")
    | let err: URLParseError =>
      h.assert_true(err is MissingHost)
    end

class \nodoc\ iso _TestURLErrorInvalidPort is UnitTest
  """Non-numeric port returns InvalidPort."""
  fun name(): String => "url/error_invalid_port"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com:abc/path")
    | let _: ParsedURL => h.fail("expected InvalidPort")
    | let err: URLParseError =>
      h.assert_true(err is InvalidPort)
    end

class \nodoc\ iso _TestURLErrorPortZero is UnitTest
  """Port 0 returns InvalidPort."""
  fun name(): String => "url/error_port_zero"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com:0/path")
    | let _: ParsedURL => h.fail("expected InvalidPort")
    | let err: URLParseError =>
      h.assert_true(err is InvalidPort)
    end

class \nodoc\ iso _TestURLErrorPortTooLarge is UnitTest
  """Port > 65535 returns InvalidPort."""
  fun name(): String => "url/error_port_too_large"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com:65536/path")
    | let _: ParsedURL => h.fail("expected InvalidPort")
    | let err: URLParseError =>
      h.assert_true(err is InvalidPort)
    end

class \nodoc\ iso _TestURLErrorUserInfo is UnitTest
  """URL with userinfo returns UserInfoNotSupported."""
  fun name(): String => "url/error_userinfo"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://user:pass@example.com/path")
    | let _: ParsedURL => h.fail("expected UserInfoNotSupported")
    | let err: URLParseError =>
      h.assert_true(err is UserInfoNotSupported)
    end

class \nodoc\ iso _TestURLValidPort65535 is UnitTest
  """Port 65535 is valid."""
  fun name(): String => "url/valid_port_65535"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com:65535/path")
    | let u: ParsedURL =>
      h.assert_eq[String val]("65535", u.port)
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

class \nodoc\ iso _TestURLQueryWithoutPath is UnitTest
  """Query string without explicit path — path defaults to /, query parsed."""
  fun name(): String => "url/query_without_path"

  fun apply(h: TestHelper) =>
    match \exhaustive\ URL.parse("http://example.com?key=value")
    | let u: ParsedURL =>
      h.assert_eq[String val]("/", u.path)
      match u.query
      | let q: String => h.assert_eq[String val]("key=value", q)
      else h.fail("expected query string")
      end
      h.assert_eq[String val]("/?key=value", u.request_path())
    | let err: URLParseError =>
      h.fail("parse failed: " + err.string())
    end

