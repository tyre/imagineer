defmodule Imagineer.Image.PNG.DataContent do
  alias Imagineer.Image.PNG
  import Imagineer.Image.PNG.Helpers, only: [bytes_per_row: 2]

  @doc """
  Takes in an image whose chunks have been processed and decompresses,
  defilters, de-interlaces, and pulls apart its pixels.
  """
  def process(%PNG{}=image) do
    PNG.Compression.decompress(image)
    |> extract_scanlines()
    |> PNG.Filter.unfilter
    |> PNG.Pixels.extract
    |> cleanup
  end

  # Removes fields that are used in intermediate steps that don't make sense
  # otherwise
  defp cleanup(%PNG{}=image) do
    %PNG{image | scanlines: [], decompressed_data: nil, unfiltered_rows: []}
  end

  @doc """
  Takes in a PNG with decompressed data and splits up the individual scanlines,
  returning the image with scanlines attached.
  A scanline is 1 byte containing the filter followed by the binary
  representation of that row of pixels (as filtered through the filter indicated
  by the first byte.)

  ## Example

        iex> alias Imagineer.Image.PNG
        iex> decompressed_data = <<1, 127, 138, 255, 20, 21, 107, 0, 233, 1, 77,
        ...> 78, 191, 144, 2, 1, 77, 16, 234, 234, 154, 3, 67, 123, 98, 142,
        ...> 117, 3, 4, 104, 44, 87, 33, 91, 188>>
        iex> updated_image = %PNG{
        ...>   decompressed_data: decompressed_data,
        ...>   color_format: :rgb8,
        ...>   width: 2
        ...> } |>
        ...> PNG.DataContent.extract_scanlines()
        iex> updated_image.scanlines
        [
          <<1, 127, 138, 255, 20, 21, 107>>,
          <<0, 233, 1, 77, 78, 191, 144>>,
          <<2, 1, 77, 16, 234, 234, 154>>,
          <<3, 67, 123, 98, 142, 117, 3>>,
          <<4, 104, 44, 87, 33, 91, 188>>
        ]
  """
  def extract_scanlines(%PNG{decompressed_data: decompressed_data}=image) do
    scanlines = extract_scanlines(decompressed_data, bytes_per_scanline(image), [])
    Map.put(image, :scanlines, scanlines)
  end

  defp extract_scanlines(<<>>, _, scanlines) do
    Enum.reverse scanlines
  end

  defp extract_scanlines(decompressed_data, bytes_per_scanline, scanlines) do
    <<scanline::bytes-size(bytes_per_scanline), rest::binary>> = decompressed_data
    extract_scanlines(rest, bytes_per_scanline, [scanline | scanlines])
  end

  # The number of bytes per scanline is equal to the number of bytes per row
  # plus one byte for the filter method.
  defp bytes_per_scanline(%PNG{color_format: color_format, width: width}) do
    bytes_per_row(color_format, width) + 1
  end
end
