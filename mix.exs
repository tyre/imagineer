defmodule Imagineer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :imagineer,
      version: "0.1.0",
      elixir: "~> 1.0",
      deps: deps,
      description: "Image processing in Elixir"
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end
end
