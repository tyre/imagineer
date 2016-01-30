defmodule Imagineer.Image.PNG.Chunk.Gamma do
  alias Imagineer.Image.PNG

  def decode(<<gamma::integer-size(32)>>, %PNG{}=image)do
    %PNG{image| gamma: gamma/100_000}
  end
end
