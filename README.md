# Plugsnag

![Elixir CI](https://github.com/bugsnag-elixir/plugsnag/workflows/Elixir%20CI/badge.svg)
[![Hex Version](https://img.shields.io/hexpm/v/plugsnag.svg)](https://hex.pm/packages/plugsnag)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/plugsnag/)
[![Total Download](https://img.shields.io/hexpm/dt/plugsnag.svg)](https://hex.pm/packages/plugsnag)
[![License](https://img.shields.io/hexpm/l/plugsnag.svg)](https://github.com/bugsnag-elixir/plugsnag/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/bugsnag-elixir/plugsnag.svg)](https://github.com/bugsnag-elixir/plugsnag/commits/master)

Report errors in your Plug stack or whatever to [Bugsnag](https://bugsnag.com),
because that's a super great place to send your errors.

## Installation/Usage

Just throw it in your deps in your `mix.exs`:

```elixir
defp deps do
  [
    {:plugsnag, "~> 1.7.0"}
  ]
end
```

Then you'll need to configure it with your API key as
per [the bugsnag-elixir docs](https://github.com/jarednorman/bugsnag-elixir).

To use the plug, `use` it in your router. For example in an Phoenix app:

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Plugsnag

  # ...
end
```

If you want to define your own `handle_errors` functions using [Plug.ErrorHandler](https://hexdocs.pm/plug/Plug.ErrorHandler.html), then you can call `Plugsnag.handle_errors/{2,3}` directly.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Plug.ErrorHandler
  # ...
  defp handle_errors(conn, assigns) do
    Plugsnag.handle_errors(conn, assigns)
    # do your own handling
  end
end
```

### Filtering Parameters and Headers

By default, the `BasicErrorReportBuilder` will filter out password parameters from error reports sent to Bugsnag. You can customize this list inside your configuration:

```elixir
config :plugsnag, filter: [params: ~w(password password_confirmation super_sekrit), headers: []]

```

By default, query strings are not filtered and may still leak sensitive information stored there
(which shouldn't be, anyway). To filter the query string in the generated report, set the
`:filter_query_string` config option to true:

```elixir
config :plugsnag, filter_query_string: true

```

## Customizing error reporting

You can also customize how an error is sent to bugsnag-elixir by passing your
own custom ErrorReportBuilder with the `:error_report_builder` option.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Plugsnag, error_report_builder: YourApp.ErrorReportBuilder

  # ...
end
```

```elixir
defmodule YourApp.ErrorReportBuilder do
  @behaviour Plugsnag.ErrorReportBuilder

  def build_error_report(error_report, conn) do
    error_report
    |> Plugsnag.BasicErrorReportBuilder.build_error_report(conn)
    |> put_user_info(conn)
  end

  defp put_user_info(error_report, conn) do
    current_user = conn.assigns[:current_user]

    user_info =  %{
      id: current_user.id
    }

    %{error_report | user: user_info}
  end
end
```

## Copyright and License

Copyright (c) 2015 Jared Norman, Andrew Harvey, Guilherme de Maio

This work is free. You can redistribute it and/or modify it under the
terms of the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
