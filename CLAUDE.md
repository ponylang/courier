# HTTP Client for Pony

## Building

```
make ssl=3.0.x      # build and run tests (OpenSSL 3.x)
make ssl=1.1.x      # build and run tests (OpenSSL 1.1.x)
make ssl=libressl   # build and run tests (LibreSSL)
make clean           # clean build artifacts
```

The `ssl` option is required because this library depends on the `ssl` package via lori.

## Dependencies

- [lori](https://github.com/ponylang/lori) 0.8.5 — TCP I/O with connection-actor model
- [ssl](https://github.com/ponylang/ssl) 2.0.0 — SSL/TLS support

## Package

Package: `courier` (repo name is `courier`, Pony package name is `courier`)

## Release Notes

Follow the standard ponylang release notes conventions. Create individual `.md` files in `.release-notes/` for each PR with user-facing changes.
