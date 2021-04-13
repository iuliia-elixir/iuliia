defmodule Iuliia.MixProject do
  use Mix.Project

  def project do
    [
      app: :iuliia,
      description: "Russian transliteration using nalgeon/iuliia schemas",
      version: "0.1.2",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/adnikiforov/iuliia-ex",
      package: package()
    ]
  end

  defp package do
    [
      name: "iuliia",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/adnikiforov/iuliia-ex"},
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
