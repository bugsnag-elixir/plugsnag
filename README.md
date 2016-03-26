### This project is looking for a maintainer. As much as I love the language, ecosystem, community around Elixir, I'm not currently lucky enough to be doing any serious work in the language. If someone would like to take some responsibility for the project I would hugely appreciate it.

# Plugsnag

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
