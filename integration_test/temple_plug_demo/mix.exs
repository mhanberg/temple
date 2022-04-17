defmodule TemplePlugDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :temple_plug_demo,
      version: "0.1.0",
      elixir: "~> 1.13",
      compilers: [:temple] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TemplePlugDemo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 0.4.9"},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:temple, path: "../../"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
