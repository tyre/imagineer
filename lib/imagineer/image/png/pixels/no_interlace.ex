defmodule Imagineer.Image.PNG.Pixels.NoInterlace do
  alias Imagineer.Image.PNG
  import PNG.Helpers, only: [channels_per_pixel: 1]

  @doc """
  Extracts the pixels from all of the unfiltered rows. Sets the `pixels` field
  on the image and returns it.

  ## Example
      iex> alias Imagineer.Image.PNG
      iex> image = %PNG{
      ...>  color_format: :rgb8,
      ...>  bit_depth: 8,
      ...>  interlace_method: 0,
      ...>  width: 2,
      ...>  height: 5,
      ...>  unfiltered_rows: [
      ...>    <<127, 138, 255, 147, 159, 106>>,
      ...>    <<233, 1, 77, 78, 191, 144>>,
      ...>    <<234, 78, 93, 56, 169, 42>>,
      ...>    <<184, 162, 144, 6, 26, 96>>,
      ...>    <<32, 206, 231, 39, 117, 76>>
      ...>  ]
      ...> }
      iex> PNG.Pixels.extract(image).pixels
      [
        [ {127, 138, 255}, {147, 159, 106} ],
        [ {233, 1, 77}, {78, 191, 144} ],
        [ {234, 78, 93}, {56, 169, 42} ],
        [ {184, 162, 144}, {6, 26, 96} ],
        [ {32, 206, 231}, {39, 117, 76} ]
      ]

  """
  def extract(%PNG{unfiltered_rows: unfiltered_rows}=image) do
    extract_pixels(unfiltered_rows, image)
  end

  def extract_pixels(rows, %PNG{color_format: color_format, bit_depth: bit_depth, width: width}) do
    extract_pixels(rows, width, channels_per_pixel(color_format), bit_depth, [])
  end

  defp extract_pixels([], _width, _channels_per_pixel, _bit_depth, pixel_rows) do
    Enum.reverse(pixel_rows)
  end

  defp extract_pixels([row | unfiltered_rows], width, channels_per_pixel, bit_depth, pixel_rows) do
    pixel_row = extract_pixels_from_row(row, width, channels_per_pixel, bit_depth)
    extract_pixels(unfiltered_rows, width, channels_per_pixel, bit_depth, [pixel_row | pixel_rows])
  end

  defp extract_pixels_from_row(row, width, channels_per_pixel, bit_depth) do
    pixel_size = channels_per_pixel * bit_depth
    extract_pixels_from_row(row, width, channels_per_pixel, bit_depth, pixel_size, [])
  end

  # In the base case, we have pulled everything from the row and are left with
  # a reversed list of pixels. It is possible that `row` is larger than the number
  # of pixels because some pixels (e.g. 1 bit grayscale) do not always fill an
  # entire byte.
  defp extract_pixels_from_row(_row, 0, _channels_per_pixel, _bit_depth, _pixel_size, pixels) do
    Enum.reverse pixels
  end

  defp extract_pixels_from_row(row, width, channels_per_pixel, bit_depth, pixel_size, pixels) do
    <<pixel_bits::bits-size(pixel_size), rest_of_row::bits>> = row
    pixel = extract_pixel(pixel_bits, bit_depth, channels_per_pixel)
    extract_pixels_from_row(rest_of_row, width - 1, channels_per_pixel, bit_depth, pixel_size, [pixel | pixels])
  end

  def extract_pixel(pixel_bits, bit_depth, channels_per_pixel) do
    extract_pixel(pixel_bits, bit_depth, [], channels_per_pixel)
  end

  # In the base case, we have no more channels to parse and we are done!
  defp extract_pixel(<<>>, _bit_depth, channel_list, 0) do
    List.to_tuple Enum.reverse channel_list
  end

  defp extract_pixel(pixel_bits, bit_depth, channel_list, channels) do
    remaining_channels = channels - 1
    rest_size = bit_depth * remaining_channels
    <<channel::integer-size(bit_depth), rest::bits-size(rest_size)>> = pixel_bits
    extract_pixel(rest, bit_depth, [channel | channel_list], remaining_channels)
  end
end
