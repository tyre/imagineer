defmodule Imagineer.Image.PNG.Chunk.Encoders.Gamma do
  alias Imagineer.Image.PNG

  def encode(%PNG{gamma: nil}), do: nil

  def encode(%PNG{gamma: gamma}) do
    normalized_gamma = round(gamma * 100_000)
    <<normalized_gamma::integer-size(32)>>
  end
end
