defmodule Imagineer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :imagineer,
      version: "0.3.0",
      elixir: "~> 1.4",
      deps: deps(),
      source_url: "https://github.com/SenecaSystems/imagineer",
      description: description(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:apex, "~>1.0.0", env: :test},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Image processing in Elixir
    """
  end

  defp package do
  [
    maintainers: maintainers(),
    links: links(),
    licenses: ["MIT"]
  ]
  end

  defp maintainers do
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
