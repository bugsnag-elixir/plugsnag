defmodule Plugsnag.Mixfile do
  use Mix.Project

  @source_url "https://github.com/bugsnag-elixir/plugsnag"
  @version "1.7.1"

  def project do
    [
      app: :plugsnag,
      version: @version,
      elixir: "~> 1.8",
      package: package(),
      deps: deps(),
      docs: docs(),
      preferred_cli_env: [docs: :docs, "hex.publish": :docs],
      dialyzer: dialyzer(Mix.env()),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  # Setup dialyzer paths for CI Cache
  defp dialyzer(:test) do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      flags: [
        :underspecs,
        :unknown,
        :unmatched_returns,
        :overspecs,
        :specdiffs,
        :extra_return,
        :missing_return
      ]
    ]
  end

  defp dialyzer(_), do: []

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
      {:dialyxir, "~> 1.2", only: [:test], runtime: false}
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
