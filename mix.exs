defmodule Temple.MixProject do
  use Mix.Project

  def project do
    [
      app: :temple,
      name: "Temple",
      description: "An HTML DSL for Elixir and Phoenix",
      version: "0.4.0",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      source_url: "https://github.com/mhanberg/temple",
      docs: [
        main: "Temple",
        extras: ["README.md"],
        deps: [
          phoenix_html: "https://hexdocs.pm/phoenix_html/"
        ]
      ]
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

  defp package do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mhanberg/temple"},
      exclude_patterns: ["temple.update_mdn_docs.ex"],
      files: ~w(lib priv CHANGELOG.md LICENSE mix.exs README.md .formatter.exs)
    ]
  end

  defp aliases do
    [
      docs: ["temple.update_mdn_docs", "docs"]
    ]
  end

  defp deps do
    [
      {:phoenix_html, "~> 2.13"},
      {:ecto, "~> 3.0", optional: true},
      {:phoenix_ecto, "~> 4.0", optional: true},
      {:ex_doc, "~> 0.0", only: [:dev], runtime: false},
      {:html_sanitize_ex, "~> 1.3", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.4", optional: true},
      {:plug, "~> 1.8", optional: true},
      {:floki, "~> 0.23.0"}
    ]
  end
end
