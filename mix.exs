defmodule Plugsnag.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugsnag,
      version: "0.0.1-dev",
      elixir: "~> 0.15.0",
      package: package,
      description: """
        A plug that catches errors and sends them to Bugsnag
      """,
     deps: deps ]
  end

  def package do
    [ contributors: [ "Jared Norman" ],
      licenses: [ "MIT" ],
      links: [ github: "https://github.com/jarednorman/plugsnag" ] ]
  end

  def application do
    [ applications: [] ]
  end

  defp deps do
    [ { :bugsnag, "~> 0.0.1", github: "jarednorman/bugsnag-elixir", branch: "phoenix_time" },
      { :cowboy, "~> 1.0.0" },
      { :plug, "~> 0.5.1" } ]
  end
end
