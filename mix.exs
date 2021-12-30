defmodule Plugsnag.Mixfile do
  use Mix.Project

  @source_url "https://github.com/bugsnag-elixir/plugsnag"
  @version "1.6.1"

  def project do
    [
      app: :plugsnag,
      version: @version,
      elixir: "~> 1.8",
      package: package(),
      deps: deps(),
      docs: docs(),
      dialyzer: [plt_add_deps: :project],
      preferred_cli_env: [docs: :docs, "hex.publish": :docs]
    ]
  end

  def package do
    [
      description: "Bugsnag reporter for Elixir's Plug",
      contributors: ["Jared Norman", "Andrew Harvey", "Guilherme de Maio"],
      maintainers: ["Andrew Harvey", "Guilherme de Maio"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://hexdocs.pm/plugsnag/changelog.html",
        GitHub: @source_url
      }
    ]
  end

  defp deps do
    [
      {:bugsnag, "~> 1.3 or ~> 2.0 or ~> 3.0"},
      {:plug, "~> 1.0"},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
