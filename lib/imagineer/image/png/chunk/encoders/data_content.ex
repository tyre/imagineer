defmodule Imagineer.Image.PNG.Chunk.Encoders.DataContent do
  alias Imagineer.Image.PNG

  def encode(%PNG{data_content: data_content}) do
    data_content
  end
end
