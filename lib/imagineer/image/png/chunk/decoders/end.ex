defmodule Imagineer.Image.PNG.Chunk.Decoders.End do
  alias Imagineer.Image.PNG

  # At the end of the PNG, we are ready to process the data content
  def decode(_content, image) do
    {:end, PNG.DataContent.process(image)}
  end
end
