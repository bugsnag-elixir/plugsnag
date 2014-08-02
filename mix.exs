defmodule Bugsnag.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugsnag,
      version: "0.0.1",
      elixir: "~> 0.14.3",
      package: package,
      description: """
        A plug that catches errors and sends them to Bugsnag]
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
    [ { :bugsnag, "~> 0.0.1", github: "jarednorman/bugnsag-elixir" } ]
  end
end
