# courier

An HTTP/1.1 client for Pony, built on [lori](https://github.com/ponylang/lori). Courier follows lori's protocol-handler-owned-by-actor pattern.

## Status

courier is beta quality software that will change frequently. Expect breaking changes. That said, you should feel comfortable using it in your projects.

## Installation

* Install [corral](https://github.com/ponylang/corral)
* `corral add github.com/ponylang/courier.git --version 0.1.0`
* `corral fetch` to fetch your dependencies
* `use "courier"` to include this package
* `corral run -- ponyc` to compile your application

You'll also need an SSL library installed on your platform. See the [ssl](https://github.com/ponylang/ssl) package for details.

## Usage

See the [examples](examples/) directory.

## API Documentation

[https://ponylang.github.io/courier](https://ponylang.github.io/courier)
