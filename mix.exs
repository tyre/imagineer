defmodule Imagineer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :imagineer,
      version: "0.2.0-dev",
      elixir: "~> 1.0",
      deps: deps,
      source_url: "https://github.com/SenecaSystems/imagineer",
      description: description,
      package: package
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:apex, "~>0.3.2", env: :test}
    ]
  end

  defp description do
    """
    Image processing in Elixir
    """
  end

  defp package do
  [
    contributors: contributors,
    links: links,
    licenses: ["MIT"]
  ]
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
