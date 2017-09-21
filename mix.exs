defmodule CFXXL.Mixfile do
  use Mix.Project

  def project do
    [app: :cfxxl,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     #Docs
     name: "CFXXL",
     source_url: "https://github.com/Ispirata/cfxxl"]
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
    [{:httpoison, "~> 0.13"},
     {:poison, "~> 3.1"},

     {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
