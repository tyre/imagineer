defmodule Imagineer.Image.PNG.Pixels.Adam7 do
  alias Imagineer.Image.PNG
  alias PNG.Interlace.Adam7
  import PNG.Helpers, only: [channels_per_pixel: 1]

  def extract(%PNG{unfiltered_rows: passes}=image) do
    extract_pixels_from_passes(passes, image)
    |> Adam7.merge({image.width, image.height})
  end

  def separate_passes(%PNG{}=image) do
    Enum.map(Adam7.separate_passes(image), fn (adam_pass) ->
      PNG.Pixels.NoInterlace.encode_pixel_rows(adam_pass, image)
    end)
  end

  defp extract_pixels_from_passes(passes, image) do
    extract_pixels_from_passes(passes, image, 1, [])
  end

  defp extract_pixels_from_passes([], _image, 8, extracted_pass_rows) do
    Enum.reverse(extracted_pass_rows)
  end

  defp extract_pixels_from_passes([pass | passes], image, pass_index, extracted_pass_rows) do
    extracted_pass = extract_pixels_from_pass(pass, image, pass_index)
    extract_pixels_from_passes(passes, image, pass_index + 1, [extracted_pass | extracted_pass_rows])
  end

  def extract_pixels_from_pass(rows, image, pass_index) do
    extract_pixels_from_pass(rows, pass_index, image, [])
  end

  defp extract_pixels_from_pass([], _pass_index, _image, pixel_rows) do
    Enum.reverse(pixel_rows)
  end

  defp extract_pixels_from_pass([row | unfiltered_rows], pass_index, image, pixel_rows) do
    {pass_width, _height} = PNG.Interlace.Adam7.Pass.size(pass_index, image.width, image.height)
    pixel_row = extract_pixels_from_row(row, pass_width, image)
    extract_pixels_from_pass(unfiltered_rows, pass_index, image, [pixel_row | pixel_rows])
  end

  defp extract_pixels_from_row(row, pass_width, %PNG{color_format: color_format, bit_depth: bit_depth}) do
    channels_per_pixel = channels_per_pixel(color_format)
    pixel_size =  channels_per_pixel * bit_depth
    extract_pixels_from_row(row, pass_width, channels_per_pixel, bit_depth, pixel_size, [])
  end

  # In the base case, we have pulled everything from the row and are left with
  # a reversed list of pixels. It is possible that `row` is larger than the number
  # of pixels because some pixels (e.g. 1 bit grayscale) do not always fill an
  # entire byte.
  defp extract_pixels_from_row(_row, 0, _channels_per_pixel, _bit_depth, _pixel_size, pixels) do
    Enum.reverse pixels
  end

  defp extract_pixels_from_row(row, pass_width, channels_per_pixel, bit_depth, pixel_size, pixels) do
    <<pixel_bits::bits-size(pixel_size), rest_of_row::bits>> = row
    pixel = extract_pixel(pixel_bits, bit_depth, channels_per_pixel)
    extract_pixels_from_row(rest_of_row, pass_width - 1, channels_per_pixel, bit_depth, pixel_size, [pixel | pixels])
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
