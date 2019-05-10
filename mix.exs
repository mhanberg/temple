defmodule Dsl.MixProject do
  use Mix.Project

  def project do
    [
      app: :dsl,
      version: "0.1.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Dsl",
      source_url: "https://github.com/mhanberg/cogent",
      docs: [
        main: "Dsl",
        extras: ["README.md"],
        deps: [
          phoenix_html: "https://hexdocs.pm/phoenix_html/"
        ]
      ],
      dialyzer: [plt_add_apps: [:mix, :phoenix, :html_sanitize_ex]]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_html, "~> 2.13"},
      {:ex_doc, "~> 0.0", only: [:dev], runtime: false},
      {:html_sanitize_ex, "~> 1.3", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.4", optional: true},
      {:plug, "~> 1.8", optional: true},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false}
    ]
  end
end
