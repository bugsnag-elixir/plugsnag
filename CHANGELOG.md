# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.7.1 (2022-11-01)
- publish `handle_errors` to avoid dialyzer error under erlang 25.1 [#53](https://github.com/bugsnag-elixir/plugsnag/pull/53)

## v1.7.0 (2022-11-01)
- add for `:filter_query_string` config option to filter values from query strings.

## v1.6.1 (2021-03-16)

### Fixed
- pass along stacktrace from Plug.ErrorHandler to Bugsnag [#44](https://github.com/bugsnag-elixir/plugsnag/pull/44)

## v1.6.0 (2020-11-25)

### Changed
- update dependency requirements to support bugsnag v3.0.0
  please check the [CHANGELOG](https://github.com/bugsnag-elixir/bugsnag-elixir/blob/master/CHANGELOG.md)

## v1.5.0 (2020-07-25)

### Added
- expose public function handle_errors/3 to allow composition

### Changed
- only report exceptions mapping to 5xx errors
- support only for elixir 1.6+
