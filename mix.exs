defmodule CFXXL.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cfxxl,
      description: "CFSSL API client for Elixir",
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "CFXXL",
      source_url: "https://github.com/Ispirata/cfxxl",
      docs: [main: "CFXXL"],

      # excoveralls
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test}
    ]
  end

  defp package do
    [
      maintainers: ["Riccardo Binetti", "Davide Bettio"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Ispirata/cfxxl"}
    ]
  end
end
