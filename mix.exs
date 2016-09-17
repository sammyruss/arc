defmodule Arc.Mixfile do
  use Mix.Project

  @version "0.5.3"

  def project do
    [app: :arc,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,

    # Hex
     description: description,
     package: package]
  end

  defp description do
    """
    Flexible file upload and attachment library for Elixir.
    """
  end

  defp package do
    [maintainers: ["Sean Stavropoulos"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/stavro/arc"},
     files: ~w(mix.exs README.md CHANGELOG.md lib)]
  end

  def application do
    [applications: [:hackney, :logger]]
  end

  defp deps do
    [
      {:ex_aws, github: "CargoSense/ex_aws", ref: "dbe871a8b6f9223f2d43cdea27028460764f1db9", override: true},
      {:poison,    "~> 1.2 or ~> 2.0",    optional: true},
      {:httpoison, "~> 0.7",    optional: true},
      {:sweet_xml, "~> 0.5", optional: true},
      {:mock,      "~> 0.1.1",  only: :test},
      {:hackney, "~> 1.6"}
    ]
  end
end
