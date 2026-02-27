# Examples

Each subdirectory is a self-contained Pony program demonstrating a different part of the courier library.

## [basic](basic/)

Connects to `example.com:80`, sends an HTTP GET request for `/`, and prints the response status, headers, and body to stdout. Demonstrates the full lifecycle: `HTTPClientConnectionActor` implementation, `on_connected` to send the request, response callbacks for status/headers/body, and connection close after completion.
