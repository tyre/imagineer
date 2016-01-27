defmodule Imagineer.Image.PNG.Interlace.Adam7.Scanlines do
  alias Imagineer.Image.PNG
  alias PNG.Interlace.Adam7.Pass
  import PNG.Helpers

  @moduledoc """
  Module for handling PNG-specific behaviour of Adam7
  """

  @doc """
  Takes in raw image content along with basic dimensions about the image.
  Converts that into seven separate "passes" for decoding. Each "pass" returned
  is a list of binaries, each binary corresponding to a scanline of pixels.

  Each scanline is composed of a 1 byte indicator of the filter method followed
  by `n` bytes where `n` is the number of bytes per scanline. `n` differs based
  on the color format of the image.

  The scanlines should be defiltered before recomposing the pixels.
  """
  def extract(%PNG{
    decompressed_data: decompressed_data, width: width, height: height
  }=image) do
    Pass.sizes(width, height)
    |> extract_passes_scanlines(image, decompressed_data)
  end

  defp extract_passes_scanlines(images_dimensions, image, content) do
    extract_passes_scanlines(images_dimensions, image, content, [])
  end

  defp extract_passes_scanlines([], _color_format, _image, passes) do
    Enum.reverse passes
  end

  defp extract_passes_scanlines([dimensions | rest_dimensions], image, content, passes) do
    {pass, rest_content} = extract_pass_scanlines(dimensions, image, content)
    extract_passes_scanlines(rest_dimensions, image, rest_content, [pass | passes])
  end

  defp extract_pass_scanlines(dimensions, image, content) do
    extract_pass_scanlines(dimensions, image, content, [])
  end

  defp extract_pass_scanlines({0, _height}, _image, content, scanlines) do
    {Enum.reverse(scanlines), content}
  end

  defp extract_pass_scanlines({_width, 0}, _image, content, scanlines) do
    {Enum.reverse(scanlines), content}
  end

  defp extract_pass_scanlines({pass_width, pass_height}, image, content, scanlines) do
    {scanline, rest_content} = extract_pass_scanline(pass_width, image, content)
    extract_pass_scanlines({pass_width, pass_height-1}, image, rest_content, [scanline | scanlines])
  end

  defp extract_pass_scanline(pass_width, image, content) do
    # There is an additional byte at the beginning of the scanline to indicate the
    # filter method.
    scanline_size = bytes_per_scanline(image, pass_width)
    <<scanline::bytes-size(scanline_size), rest_content::bits>> = content
    {scanline, rest_content}
  end

  # The number of bytes per scanline is equal to the number of bytes per row
  # plus one byte for the filter method.
  defp bytes_per_scanline(%PNG{color_format: color_format, bit_depth: bit_depth}, pass_width) do
    bytes_per_row(color_format, bit_depth, pass_width) + 1
  end
end
