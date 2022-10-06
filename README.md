# PdPlugsnag

** DO NOT MERGE **

_This branch is the `pd_plugsnag` fork, it has to be kept separate from main/master. A lot of PagerDuty projects use this repo
as a dependency without specifying a tag and they know it by the name `plugsnag`. If this gets merged in, it's likely to 
cause all kinds of problems._

Report errors in your Plug stack or whatever to [Bugsnag](https://bugsnag.com),
because that's a super great place to send your errors.

:exclamation: This is a PagerDuty fork of the plugsnag package: https://github.com/bugsnag-elixir/plugsnag
It has deviated a bit from the upstream project as of version 1.4.1, with no specific intention
of resynchronizing.

## Installation/Usage

Just throw it in your deps in your `mix.exs` (note that the repo name is different than the package name!):

```elixir
  defp deps do
    [{:pd_plugsnag, github: "PagerDuty/plugsnag", tag: "pd/v1.5.0"}]
  end
```

Then you'll need to configure it with your API key as
per [the bugsnag-elixir
docs](https://github.com/jarednorman/bugsnag-elixir).

To use the plug, `use` it in your router. For example in an Phoenix app:

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use PdPlugsnag

  # ...
end
```

## Filtering Parameters and Headers

By default, the `BasicErrorReportBuilder` will filter out parameters name "password" from error reports sent to Bugsnag. You can customize this list inside your configuration:

```elixir
config :pd_plugsnag, filter: [params: ~w(password password_confirmation super_sekrit), headers: []]
```

You can filter values from three places:
- The request body (using the `:params` option)
- The query string parameters (using the `:query_string` option)
- The request headers (using the `:headers` option)

## Customizing error reporting

You can also customize how an error is sent to bugsnag-elixir by passing your
own custom ErrorReportBuilder with the `:error_report_builder` option.

```elixir
defmodule YourApp.Router do
  use Phoenix.Router
  use PdPlugsnag, error_report_builder: YourApp.ErrorReportBuilder

  # ...
end
```

```elixir
defmodule YourApp.ErrorReportBuilder do
  @behaviour PdPlugsnag.ErrorReportBuilder

  def build_error_report(error_report, conn) do
    error_report
    |> PdPlugsnag.BasicErrorReportBuilder.build_error_report(conn)
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

## Migrating from the Upstream `plugsnag` Package

If you've been using the upstream `plugsnag` package up to version 1.4.1
(also published to hex.pm), or the PagerDuty fork up to version 1.4.1,
you can migrate to using this version, `pd_plugsnag` as follows:

* Change any config you have for `:plugsnag` to `:pd_plugsnag`.
* Change any module references to `Plugsnag` to `PdPlugsnag`.

If you've been using either of those beyond version 1.4.1, you will need
to check those packages for other differences they've instroduced since
version 1.4.1
