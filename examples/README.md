# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the courier library.

## [basic](basic/)

Connects to `example.com:80`, sends an HTTP GET request for `/`, and prints the response status, headers, and body to stdout. Demonstrates the full lifecycle: `HTTPClientConnectionActor` implementation, `on_connected` to send the request, response callbacks for status/headers/body, and connection close after completion. Uses `ResponseCollector` to accumulate streaming body chunks into a single `HTTPResponse`.

## [json-api](json-api/)

Connects to `jsonplaceholder.typicode.com` over HTTPS, fetches a JSON todo item, parses the response, and prints selected fields. Demonstrates `Request` builder for request construction, `ResponseCollector` for body accumulation, `ResponseJson` for JSON parsing, and `HTTPClientConnection.ssl()` for TLS connections.
