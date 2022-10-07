# Changelog

## v1.7.0
- add for `:filter_query_string` config option to filter values from query strings.

## v1.6.1

### Fixed
- pass along stacktrace from Plug.ErrorHandler to Bugsnag [#44](https://github.com/bugsnag-elixir/plugsnag/pull/44)

## v1.6.0

### Changed
- update dependency requirements to support bugsnag v3.0.0
  please check the [CHANGELOG](https://github.com/bugsnag-elixir/bugsnag-elixir/blob/master/CHANGELOG.md)

## v1.5.0

### Added
- expose public function handle_errors/3 to allow composition

### Changed
- only report exceptions mapping to 5xx errors
- support only for elixir 1.6+
