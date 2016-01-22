defmodule Imagineer.Image.PNG.DataContent do
  alias Imagineer.Image.PNG

  @doc """
  Takes in an image whose chunks have been processed and decompresses,
  defilters, de-interlaces, and pulls apart its pixels.
  """
  def process(%PNG{}=image) do
    PNG.Compression.decompress(image)
    |> PNG.Interlace.extract_pixels
    |> cleanup
  end

  # Removes fields that are used in intermediate steps that don't make sense
  # otherwise
  defp cleanup(%PNG{}=image) do
    %PNG{image | scanlines: [], decompressed_data: nil, unfiltered_rows: []}
  end
end
