defmodule Imagineer.Image.PNG.Palette do
  alias Imagineer.Image.PNG

  @moduledoc """
  Packing and unpacking palettes.

  PNGs can optionally store all colors that they
  use in a palette, then have their pixels simply reference one of those colors
  instead of encoding them all individually.

  Sometimes this can reduce file size and/or improve compression. When is this
  the case? This library author has no idea.
  """

  def unpack(%PNG{color_type: 3, palette: palette, pixels: pixels}=image) do
    %PNG{image | pixels: extract_pixels_from_palette(pixels, palette)}
  end

  # If the image doesn't have a color type of 3, it doesn't use a palette
  def unpack(image) do
    image
  end

  def pack(%PNG{color_type: 3}) do
    raise("Palette encoding not yet supported :(")
  end

  def pack(image) do
    image
  end

  defp extract_pixels_from_palette(palette_rows, palette) do
    extract_pixels_from_palette(palette_rows, palette, [])
  end

  # In the base case, we will have a reversed list of lists. Each list refers to
  # a row of pixels.
  defp extract_pixels_from_palette([], _palette, extracted_palette) do
    Enum.reverse(extracted_palette)
  end

  defp extract_pixels_from_palette([palette_row | palette_rows], palette, extracted_palette) do
    row_pixels = extract_pixels_from_palette_row(palette_row, palette, [])
    extract_pixels_from_palette(palette_rows, palette, [row_pixels | extracted_palette])
  end

  # In the base case, we are left with a row of pixels. Reverse them and we're
  # finished.
  defp extract_pixels_from_palette_row([], _palette, pixels) do
    Enum.reverse(pixels)
  end

  defp extract_pixels_from_palette_row([{palette_index} | palette_indices], palette, pixels) do
    pixel = :array.get(palette_index, palette)
    extract_pixels_from_palette_row(palette_indices, palette, [pixel | pixels])
  end
end
