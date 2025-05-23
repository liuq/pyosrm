# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- CLI tools
- Windows and MacOS wheels
- Table api
- Trip api
- Nearest api

## [0.0.3] - 2021-02-09
### Changed
- The `route` function has been fully exposed so to allow also obtaining further
  route annotations (e.g., speeds, distances, etc.)

## [0.0.2] - 2020-03-08
### Changed
- Now path parameter is optional, and you can use either a valid path or
  use_shared_memory=True to initialize a PyOSRM object

### Added
- path or use_shared_memory validation on PyOSRM object initialization

## [0.0.1] - 2020-03-03
### Added
- PyOSRM class with working route method
- RouterResult class
- Status enum
- Working examples on readme and tests
- test data unprocessed (raw) and preprocessed for CH and MLD

## [0.1.0] - 2023-04-02
### Added
- Nearest and Table methods
- Updated test files to osrm version 5.27.1

## [0.1.1] - 2025-04-09
### Changed
- directory structure
- support for poetry development along with pip
