defmodule Iuliia.MixProject do
  use Mix.Project

  @gh "https://github.com/iuliia-elixir/iuliia"

  def project do
    [
      app: :iuliia,
      description: "Russian transliteration using nalgeon/iuliia schemas",
      version: "0.1.3",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @gh,
      package: package()
    ]
  end

  defp package do
    [
      name: "iuliia",
      licenses: ["MIT"],
      links: %{"Github" => @gh},
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end

  def application do
    [
      mod: {Iuliia.Application, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
