defmodule PdPlugsnag.Mixfile do
  use Mix.Project

  def project do
    [app: :pd_plugsnag,
     version: "2.0.0",
     elixir: "~> 1.8",
     package: package(),
     description: """
      A Bugsnag reporter for Elixir's Plug.

      This is a PagerDuty fork of the plugsnag package: https://github.com/bugsnag-elixir/plugsnag
      It has deviated a bit from the upstream project as of version 1.4.1, with no specific intention
      of resynchronizing.
     """,
     deps: deps(),
     dialyzer: [plt_add_deps: :project]
   ]
  end

  def package do
    [contributors: ["Jared Norman", "Andrew Harvey"],
     maintainers: ["Andrew Harvey"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/jarednorman/plugsnag"}]
  end

  def application do
    [
      applications: [],
      extra_applications: [:plug]
    ]
  end

  defp deps do
    [{:bugsnag, "~> 1.3 or ~> 2.0 or ~> 3.0"},
     {:httpoison, "~> 1.8"},
     {:plug, "~> 1.0"},
     {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end
end
