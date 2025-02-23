defmodule Temple.MixProject do
  use Mix.Project

  def project do
    [
      app: :temple,
      name: "Temple",
      description: "An HTML DSL for Elixir",
      version: "0.15.0",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/mhanberg/temple",
      docs: docs()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test) do
    # hack to get the right compiler options used on the non-script files in
    # test/support
    Code.put_compiler_option(
      :parser_options,
      Keyword.put(Code.get_compiler_option(:parser_options), :token_metadata, true)
    )

    ["lib", "test/support"]
  end

  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs() do
    [
      main: "Temple",
      extras: [
        "README.md",
        "guides/getting-started.md",
        "guides/your-first-template.md",
        "guides/components.md",
        "guides/converting-html.md",
        "guides/migrating/0.8-to-0.9.md",
        "guides/migrating/0.10-to-0.11.md"
      ],
      groups_for_extras: groups_for_extras()
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r/guides\/[^\/]+\.md/,
      Migrating: ~r/guides\/migrating\/.?/
    ]
  end

  defp package do
    [
      maintainers: ["Mitchell Hanberg"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/mhanberg/temple"},
      files: ~w(lib CHANGELOG.md LICENSE mix.exs README.md .formatter.exs)
    ]
  end

  defp deps do
    [
      {:floki, ">= 0.0.0"},
      {:phoenix_html, "~> 3.2 or ~> 4.0"},
      {:typed_struct, "~> 0.3"},
      {:ex_doc, "~> 0.37.0", only: :dev, runtime: false}
    ]
  end
end
