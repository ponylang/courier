# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the courier library. Ordered from simplest to most involved.

## [basic](basic/)

Connects to `example.com:80`, sends an HTTP GET request for `/`, and prints the response status, headers, and body to stdout. Demonstrates the full lifecycle: `HTTPClientConnectionActor` implementation, `on_connected` to send the request, response callbacks for status/headers/body, and connection close after completion. Uses `ResponseCollector` to accumulate streaming body chunks into a single `HTTPResponse`. Start here if you're new to the library.

## [query-params](query-params/)

Connects to `httpbin.org` over HTTPS and sends a GET request with percent-encoded query parameters. Demonstrates the `Request` builder's `.query()` method for appending RFC 3986 encoded parameters to the request path. httpbin.org echoes the parameters back in a JSON response.

## [bearer-auth](bearer-auth/)

Connects to `httpbin.org` over HTTPS and sends a GET request with a Bearer token in the Authorization header. Demonstrates the `Request` builder's `.bearer_auth()` method for setting token-based authentication. httpbin.org echoes the request headers back so you can verify the Authorization header.

## [form-post](form-post/)

Connects to `httpbin.org` over HTTPS and POSTs form-encoded data. Demonstrates `Request.post()` with `.form_body()` for `application/x-www-form-urlencoded` POST requests. httpbin.org echoes the submitted form fields back in a JSON response.

## [json-api](json-api/)

Connects to `jsonplaceholder.typicode.com` over HTTPS, fetches a JSON todo item, parses the response, and prints selected fields. Demonstrates `Request` builder for request construction, `ResponseCollector` for body accumulation, `ResponseJson` for JSON parsing, and `HTTPClientConnection.ssl()` for TLS connections.
