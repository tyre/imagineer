defmodule Imagineer.Image.PNG.DataContent do
  alias Imagineer.Image.PNG

  @doc """
  Takes in an image whose chunks have been processed and decompresses,
  de-interlaces, unfilters, pulls apart its pixels, and (optionally) unpacks the
  palette.

  Like any good citizen, cleans up after itself and returns the resulting image.
  """
  def process(%PNG{} = image) do
    PNG.Compression.decompress(image)
    |> PNG.Interlace.extract_pixels()
    |> PNG.Filter.unfilter()
    |> PNG.Pixels.extract()
    |> PNG.Palette.unpack()
    |> cleanup
  end

  @doc """
  Turns pixels into the content for the IDAT header.
  """
  def encode(%PNG{} = image) do
    PNG.Palette.pack(image)
    |> PNG.Pixels.encode()
    |> PNG.Filter.filter()
    |> PNG.Interlace.encode_scanlines()
    |> PNG.Compression.compress()
    |> cleanup
  end

  # Removes fields that are used in intermediate steps that don't make sense
  # otherwise. This way, if pixels change, we aren't worried about stale data
  defp cleanup(%PNG{} = image) do
    %PNG{image | scanlines: [], decompressed_data: nil, unfiltered_rows: []}
  end
end
