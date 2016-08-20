# Plugsnag [![Build Status](https://travis-ci.org/jarednorman/plugsnag.svg?branch=master)](https://travis-ci.org/jarednorman/plugsnag)

Report errors in your Plug stack or whatever to [Bugsnag](https://bugsnag.com),
because that's a super great place to send your errors.

## Installation/Usage

Just throw it in your deps in your `mix.exs`:

```elixir
  defp deps do
    [{:plugsnag, "~> 1.1.0"}]
  end
```

Then you'll need to configure it with your API key as
per [the bugsnag-elixir
docs](https://github.com/jarednorman/bugsnag-elixir).

Now you'll need to call `Bugsnag.start` to warm up the card, and then `use` it,
for example in your `Phoenix.Router`.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use Plugsnag

  # ...
end
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
