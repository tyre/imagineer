defmodule Imagineer.Image.PNG.Interlace.Adam7 do
  alias Imagineer.Image.PNG
  import Imagineer.Image.PNG.Helpers, only: [bytes_per_row: 2]

  @moduledoc """
  Adam7 interlacing involves overlaying the following 8x8 grid repeatedly from
  top to bottom and left to right across the pixels:

  ```
  1 6 4 6 2 6 4 6
  7 7 7 7 7 7 7 7
  5 6 5 6 5 6 5 6
  7 7 7 7 7 7 7 7
  3 6 4 6 3 6 4 6
  7 7 7 7 7 7 7 7
  5 6 5 6 5 6 5 6
  7 7 7 7 7 7 7 7
  ```

  The numbers represent at which "pass" the pixels will be sent. All of the
  first pass pixels are sent in order first, followed by the second, followed by
  the third, etc. through pass seven. This allows PNG renderers to quickly get a
  rough view of the image rendered and progressively improve it as more
  information becomes available.

  That's what they say, anyway. It could all be made up just to mess with
  programmers.
  """

  @compile {
    :inline, div8: 1, first_pass_pixels_count: 2, second_pass_pixels_count: 2,
    third_pass_pixels_count: 2, fourth_pass_pixels_count: 2,
    fifth_pass_pixels_count: 2, sixth_pass_pixels_count: 2,
    seventh_pass_pixels_count: 2
  }

  def extract_scanlines(image) do
    Enum.zip(bytes_per_scanline(image), scanlines_per_pass(image))
    |> extract_scanlines(image)
  end

  defp extract_pixels(scanlines_and_pixel_counts, %PNG{color_format: color_format}) do
    bits_per_pixel = bits_per_pixel(color_format)
  end

  # We'll get a list of `{bytes_per_scanline, number_of_scanlines}` ordered by
  # their pass number.
  # For each one, we'll end up extracting  the first
  # `bytes_per_scanline * number_of_scanlines` bytes off of `decompressed_data`.
  # Those will be broken into their component scanlines and returned.
  #
  # This means that the return value will be a list of length 7 comprised of
  # lists of individual unfiltered scanlines.
  defp extract_scanlines(byte_and_scanline_counts, image) do
    extract_scanlines(byte_and_scanline_counts, image.decompressed_data, [])
  end

  defp extract_scanlines([], _decompressed_data, scanlines) do
    Enum.reverse(scanlines)
  end

  defp extract_scanlines([{byte_count, scanline_count} | rest], decompressed_data, scanlines) do
    {decompressed_data, new_scanlines} =
      extract_scanlines_for_pass(byte_count, scanline_count, decompressed_data, [])
    extract_scanlines(rest, decompressed_data, [new_scanlines | scanlines])
  end

  defp extract_scanlines_for_pass(_byte_count, 0, decompressed_data, scanlines) do
    {decompressed_data, Enum.reverse(scanlines)}
  end

  defp extract_scanlines_for_pass(byte_count, scanline_count, decompressed_data, scanlines) do
    <<scanline::bytes-size(byte_count), rest_data::binary>> = decompressed_data
    extract_scanlines_for_pass(byte_count, scanline_count - 1, rest_data, [scanline | scanlines])
  end

  @doc """
    Returns the number of bytes present in each row for a given pass
  """
  def bytes_per_scanline(%PNG{width: width, color_format: color_format}) do
    [
      first_pass_bytes_per_scanline(width, color_format),
      second_pass_bytes_per_scanline(width, color_format),
      third_pass_bytes_per_scanline(width, color_format),
      fourth_pass_bytes_per_scanline(width, color_format),
      fifth_pass_bytes_per_scanline(width, color_format),
      sixth_pass_bytes_per_scanline(width, color_format),
      seventh_pass_bytes_per_scanline(width, color_format)
    ]
  end

  defp first_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, first_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp second_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, second_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp third_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, third_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp fourth_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, fourth_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp fifth_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, fifth_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp sixth_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, sixth_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp seventh_pass_bytes_per_scanline(width, color_format) do
    bytes_per_row(color_format, seventh_pass_pixels_per_scanline(width))
    |> filter_length
  end

  defp pixels_per_scanline(%PNG{width: width}) do
    [
      first_pass_pixels_per_scanline(width),
      second_pass_pixels_per_scanline(width),
      third_pass_pixels_per_scanline(width),
      fourth_pass_pixels_per_scanline(width),
      fifth_pass_pixels_per_scanline(width),
      sixth_pass_pixels_per_scanline(width),
      seventh_pass_pixels_per_scanline(width)
    ]
  end

  defp first_pass_pixels_per_scanline(width) do
     div8(width + 7)
  end

  defp second_pass_pixels_per_scanline(width) do
     div8(width + 3)
  end

  defp third_pass_pixels_per_scanline(width) do
     div8(width + 3) + div8(width + 7)
  end

  defp fourth_pass_pixels_per_scanline(width) do
     div8(width + 1) + div8(width + 5)
  end

  defp fifth_pass_pixels_per_scanline(width) do
     div(width + 1, 2)
  end

  defp sixth_pass_pixels_per_scanline(width) do
     div(width, 2)
  end

  defp seventh_pass_pixels_per_scanline(width) do
     width
  end

  def scanlines_per_pass(%PNG{height: height}) do
    [
      first_pass_scanline_count(height),
      second_pass_scanline_count(height),
      third_pass_scanline_count(height),
      fourth_pass_scanline_count(height),
      fifth_pass_scanline_count(height),
      sixth_pass_scanline_count(height),
      seventh_pass_scanline_count(height)
    ]
  end

  defp first_pass_scanline_count(height) do
    div8(height + 7)
  end

  defp second_pass_scanline_count(height) do
    div8(height + 7)
  end

  defp third_pass_scanline_count(height) do
    div8(height + 3)
  end

  defp fourth_pass_scanline_count(height) do
    div8(height + 7) + div8(height + 3)
  end

  defp fifth_pass_scanline_count(height) do
    div8(height + 5) + div8(height + 1)
  end

  defp sixth_pass_scanline_count(height) do
    div(height + 1, 2)
  end

  defp seventh_pass_scanline_count(height) do
    div(height, 2)
  end


  @doc """
    Returns the number of pixels present in each pass.
  """
  def pixel_counts_per_pass(%PNG{height: height, width: width}) do
    [
      first_pass_pixels_count(height, width),
      second_pass_pixels_count(height, width),
      third_pass_pixels_count(height, width),
      fourth_pass_pixels_count(height, width),
      fifth_pass_pixels_count(height, width),
      sixth_pass_pixels_count(height, width),
      seventh_pass_pixels_count(height, width)
    ]
  end

  defp first_pass_pixels_count(height, width) do
    first_pass_pixels_per_scanline(width) * first_pass_scanline_count(height)
  end

  defp second_pass_pixels_count(height, width) do
    second_pass_pixels_per_scanline(width) * second_pass_scanline_count(height)
  end

  defp third_pass_pixels_count(height, width) do
    third_pass_pixels_per_scanline(width) * third_pass_scanline_count(height)
  end

  defp fourth_pass_pixels_count(height, width) do
    fourth_pass_pixels_per_scanline(width) * fourth_pass_scanline_count(height)
  end

  defp fifth_pass_pixels_count(height, width) do
    fifth_pass_pixels_per_scanline(width) * fifth_pass_scanline_count(height)
  end

  defp sixth_pass_pixels_count(height, width) do
    sixth_pass_pixels_per_scanline(width) * sixth_pass_scanline_count(height)
  end

  defp seventh_pass_pixels_count(height, width) do
    seventh_pass_pixels_per_scanline(width) *
    seventh_pass_scanline_count(height)
  end

  defp filter_length(0), do: 0
  defp filter_length(number_of_bytes), do: number_of_bytes + 1

  defp div8(num) do
    div(num, 8)
  end
end

# 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
