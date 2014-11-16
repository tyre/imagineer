defmodule Imagineer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :imagineer,
      version: "0.1.0",
      elixir: "~> 1.0",
      deps: deps,
      description: "Image processing in Elixir",
      source_url: "https://github.com/SenecaSystems/imagineer",
      contributors: contributors,
      links: links
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    []
  end

  defp contributors do
    [
      "Chris Maddox"
    ]
  end

  defp links do
    %{
      github: "https://github.com/SenecaSystems/imagineer"
    }
  end
  
end
