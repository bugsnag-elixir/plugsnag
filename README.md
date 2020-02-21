# Plugsnag [![Build Status](https://travis-ci.org/jarednorman/plugsnag.svg?branch=master)](https://travis-ci.org/jarednorman/plugsnag)

Report errors in your Plug stack or whatever to [Bugsnag](https://bugsnag.com),
because that's a super great place to send your errors.

## Installation/Usage

Just throw it in your deps in your `mix.exs`:

```elixir
  defp deps do
    [{:plugsnag, "~> 1.4.0"}]
  end
```

Then you'll need to configure it with your API key as
per [the bugsnag-elixir
docs](https://github.com/jarednorman/bugsnag-elixir).

If you're using Elixir < 1.4 make sure that `plugsnag` and `bugsnag` apps are started in your mix.exs. If you are using Elixir 1.4, the applications will be automatically started because they are dependencies.

For example:

```elixir
def application do
    [mod: {MyApp, []},
     applications: [:logger, :plugsnag, :bugsnag]
    ]
  end
```

To use the plug, `use` it in your router. For example in an Phoenix app:

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Plugsnag

  # ...
end
```

### Filtering Parameters and Headers

By default, the `BasicErrorReportBuilder` will filter out password parameters from error reports sent to Bugsnag. You can customize this list inside your configuration:

```elixir
config :plugsnag, filter: [params: ~w(password password_confirmation super_sekrit), headers: []]

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
