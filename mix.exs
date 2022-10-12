defmodule Plugsnag.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plugsnag,
      version: "1.6.1",
      elixir: "~> 1.8",
      package: package(),
      description: "Bugsnag reporter for Elixir's Plug",
      deps: deps(),
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
      {:dialyxir, "~> 1.2", only: [:test], runtime: false}
    ]
  end
end
