defmodule Plugsnag.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugsnag,
      version: "0.0.1",
      elixir: "~> 0.14.3",
      deps: deps ]
  end

  def application do
    [ applications: [] ]
  end

  defp deps do
    [ { :bugsnag, "~> 0.0.1", github: "jarednorman/bugnsag-elixir" } ]
  end
end
