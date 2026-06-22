# Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/) and [Keep a CHANGELOG](http://keepachangelog.com/).

## [unreleased] - unreleased

### Fixed


### Added


### Changed


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

