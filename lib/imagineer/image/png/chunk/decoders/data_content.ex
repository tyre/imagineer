defmodule Imagineer.Image.PNG.Chunk.Decoders.DataContent do
  alias Imagineer.Image.PNG

  # Process the "IDAT" chunk
  # There can be multiple IDAT chunks to allow the encoding system to control
  # memory consumption. Append the content, since it is really just one stream
  # of compressed bits
  def decode(content, %PNG{data_content: data_content}=image) do
    %PNG{image | data_content: data_content <> content}
  end
end
