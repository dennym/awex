defmodule AWeX.MixProject do
  use Mix.Project

  @source_url "https://github.com/dennym/awex"
  @version "0.0.1"

  def project do
    [
      app: :awex,
      version: @version,
      elixir: "~> 1.14",
      name: "AWeX",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "Simple Elixir wrapper for the AWX API",
      maintainers: ["Denny Mueller"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end


  defp deps do
    [
      {:finch, "~> 0.16"},
      {:jason, "~> 1.4"},
      {:inch_ex, github: "rrrene/inch_ex", only: [:dev, :test]},
      {:exvcr, "~> 0.13.5", only: :test},
      {:meck, "~> 0.9.2", only: :test}
    ]
  end
end
