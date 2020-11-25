defmodule Plugsnag.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plugsnag,
      version: "1.6.0",
      elixir: "~> 1.8",
      package: package(),
      description: "Bugsnag reporter for Elixir's Plug",
      deps: deps(),
      dialyzer: [plt_add_deps: :project]
    ]
  end

  def package do
    [
      contributors: ["Jared Norman", "Andrew Harvey", "Guilherme de Maio"],
      maintainers: ["Andrew Harvey", "Guilherme de Maio"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/bugsnag-elixir/plugsnag"}
    ]
  end

  defp deps do
    [
      {:bugsnag, "~> 1.3 or ~> 2.0 or ~> 3.0"},
      {:plug, "~> 1.0"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
