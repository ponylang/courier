# Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a CHANGELOG](http://keepachangelog.com/).

## [unreleased] - unreleased

### Fixed


### Added


### Changed

- Update to work with ponyc 0.70.0 ([PR #92](https://github.com/ponylang/courier/pull/92))

## [0.7.0] - 2026-08-21

### Changed

- Update to work with Pony 0.69.0 ([PR #89](https://github.com/ponylang/courier/pull/89))
- Require ponyc 0.69.1 or later ([PR #91](https://github.com/ponylang/courier/pull/91))

## [0.6.0] - 2026-08-10

### Fixed

- Fix on_closed firing twice when closing a backed-up connection ([PR #84](https://github.com/ponylang/courier/pull/84))

### Added

- Add opt-in redirect following ([PR #63](https://github.com/ponylang/courier/pull/63))

### Changed

- Remove Stringable from error types ([PR #81](https://github.com/ponylang/courier/pull/81))
- Replace yield_read() with a settable read buffer size ([PR #83](https://github.com/ponylang/courier/pull/83))
- Switch URL handling to ponylang/uri ([PR #86](https://github.com/ponylang/courier/pull/86))

## [0.5.0] - 2026-08-07

### Fixed

- Fix a hang when closing a connection from a response callback ([PR #68](https://github.com/ponylang/courier/pull/68))
- Fix a connection stalling under sustained write backpressure ([PR #68](https://github.com/ponylang/courier/pull/68))
- Fix backpressure not stopping incoming data on an HTTPS connection ([PR #68](https://github.com/ponylang/courier/pull/68))
- Fix yield_read() not taking effect on an HTTPS connection ([PR #68](https://github.com/ponylang/courier/pull/68))
- Fix a hang when writing to a socket under load ([PR #68](https://github.com/ponylang/courier/pull/68))
- Fix additional SSL connection bugs ([PR #75](https://github.com/ponylang/courier/pull/75))
- Fix a macOS bug where setting up a connection could close an unrelated file descriptor ([PR #75](https://github.com/ponylang/courier/pull/75))
- Send TLS close_notify on graceful close ([PR #77](https://github.com/ponylang/courier/pull/77))

### Changed

- Require ponyc 0.67.0 or later ([PR #68](https://github.com/ponylang/courier/pull/68))
- Move to ponylang/ssl 4.0.0 ([PR #68](https://github.com/ponylang/courier/pull/68))

## [0.4.0] - 2026-06-30

### Fixed

- Fix connections closed mid-transfer by the idle timeout ([PR #62](https://github.com/ponylang/courier/pull/62))

### Changed

- Drop support for Windows 10 ([PR #60](https://github.com/ponylang/courier/pull/60))

## [0.3.1] - 2026-06-22

### Fixed

- Fix response never arriving after sending a large request ([PR #59](https://github.com/ponylang/courier/pull/59))

## [0.3.0] - 2026-05-28

### Changed

- Require ponyc 0.64.0 or later ([PR #56](https://github.com/ponylang/courier/pull/56))

## [0.2.1] - 2026-04-15

### Added

- Add on_timer_failure callback ([PR #49](https://github.com/ponylang/courier/pull/49))

## [0.2.0] - 2026-04-12

### Fixed

- Fix potential connection hang when timer event subscription fails ([PR #48](https://github.com/ponylang/courier/pull/48))

### Changed

- Add ConnectionFailedTimerError to ConnectionFailureReason ([PR #48](https://github.com/ponylang/courier/pull/48))
- Require ponyc 0.63.1 or later ([PR #48](https://github.com/ponylang/courier/pull/48))

## [0.1.5] - 2026-04-07

### Fixed

- Fix connection stall after large request with backpressure ([PR #47](https://github.com/ponylang/courier/pull/47))

## [0.1.4] - 2026-03-28

### Fixed

- Fix crash when closing a connection before initialization completes ([PR #43](https://github.com/ponylang/courier/pull/43))

## [0.1.3] - 2026-03-24

### Added

- Expose one-shot timer API ([PR #42](https://github.com/ponylang/courier/pull/42))

## [0.1.2] - 2026-03-22

### Fixed

- Fix SSL connection idle timeout issues ([PR #39](https://github.com/ponylang/courier/pull/39))
- Fix connection resource leak on early close ([PR #39](https://github.com/ponylang/courier/pull/39))

### Added

- Add connection timeout support ([PR #39](https://github.com/ponylang/courier/pull/39))

### Changed

- Update ponylang/ssl to 2.0.1 ([PR #38](https://github.com/ponylang/courier/pull/38))

## [0.1.1] - 2026-03-15

### Fixed

- Fix dispose() hanging when peer FIN is missed ([PR #33](https://github.com/ponylang/courier/pull/33))

## [0.1.0] - 2026-03-02

### Added

- Initial version

