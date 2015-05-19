defmodule Plugsnag.Mixfile do
  use Mix.Project

  def project do
    [app: :plugsnag,
     version: "1.0.0",
     elixir: "~> 1.0",
     package: package,
     description: """
       Bugsnag reporter for Elixir's Plug
     """,
     deps: deps]
  end

  def package do
    [contributors: ["Jared Norman"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/jarednorman/plugsnag"}]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:bugsnag, "~> 1.0.0"}]
  end
end
