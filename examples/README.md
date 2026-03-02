# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the courier library. Ordered from simplest to most involved.

## [url-parsing](url-parsing/)

Parses `https://httpbin.org/get?source=courier` with `URL.parse()` and prints the decomposed components: scheme, host, port, path, query, `request_path()`, and `is_ssl()`. Demonstrates `URL.parse()` for URL decomposition and error handling via the `URLParseError` union.

## [basic](basic/)

Connects to `example.com:80`, sends an HTTP GET request for `/`, and prints the response status, headers, and body to stdout. Demonstrates the full lifecycle: `HTTPClientConnectionActor` implementation, `on_connected` to send the request, response callbacks for status/headers/body, exhaustive `ConnectionFailureReason` matching in `on_connection_failure`, and connection close after completion. Uses `ResponseCollector` to accumulate streaming body chunks into a single `HTTPResponse`. Start here if you're new to the library.

## [query-params](query-params/)

Connects to `httpbin.org` over HTTPS and sends a GET request with percent-encoded query parameters. Demonstrates the `Request` builder's `.query()` method for appending RFC 3986 encoded parameters to the request path. httpbin.org echoes the parameters back in a JSON response.

## [bearer-auth](bearer-auth/)

Connects to `httpbin.org` over HTTPS and sends a GET request with a Bearer token in the Authorization header. Demonstrates the `Request` builder's `.bearer_auth()` method for setting token-based authentication. httpbin.org echoes the request headers back so you can verify the Authorization header.

## [form-post](form-post/)

Connects to `httpbin.org` over HTTPS and POSTs form-encoded data. Demonstrates `Request.post()` with `.form_body()` for `application/x-www-form-urlencoded` POST requests. httpbin.org echoes the submitted form fields back in a JSON response.

## [multipart-upload](multipart-upload/)

Connects to `httpbin.org` over HTTPS and POSTs a multipart form with a text field and a file attachment. Demonstrates `MultipartFormData` with `Request.post().multipart_body()` for `multipart/form-data` uploads. httpbin.org echoes the submitted form data and files back in a JSON response.

## [json-api](json-api/)

Connects to `jsonplaceholder.typicode.com` over HTTPS, fetches a JSON todo item, decodes the response into a typed `Todo` object, and prints selected fields. Demonstrates `Request` builder for request construction, `ResponseCollector` for body accumulation, `JSONDecoder` and `DecodeJSON` for typed JSON decoding, and `HTTPClientConnection.ssl()` for TLS connections.
