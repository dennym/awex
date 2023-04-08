defmodule Awex.MixProject do
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
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
