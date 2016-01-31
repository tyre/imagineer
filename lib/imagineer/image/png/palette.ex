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

  def pack(%PNG{color_type: 3}=image) do
    build_palette_map(image)
    |> replace_pixels
    |> convert_palette_map_to_array
  end

  def pack(image) do
    image
  end

  defp build_palette_map(%PNG{pixels: pixels, background: background}=image) do
    palette_map = Enum.reduce(pixels, %{}, fn(pixel_row, palette_map) ->
      Enum.reduce(pixel_row, palette_map, fn(pixel, palette_map) ->
        # The size will be the index in the pixel array
        Map.put_new(palette_map, pixel, Dict.size(palette_map))
      end)
    end)

    # If there is a background, it could be a color that never appears on the
    # image. If so, we have to ensure it is in the palette
    if background do
      palette_map = Map.put_new(palette_map, background, Dict.size(palette_map))
    end
    %PNG{image | palette: palette_map}
  end

  defp replace_pixels(%PNG{pixels: pixels, palette: palette_map}=image) do
    %PNG{image | pixels: dereferenced_pixels(pixels, palette_map)}
  end

  defp dereferenced_pixels(pixels, palette_map) do
    Enum.reduce(pixels, [], fn (row, new_pixels) ->
      new_row = Enum.reduce(row, [], fn (pixel, new_row) ->
        # We wrap the index in a tuple since it is a pixel
        [{Map.get(palette_map, pixel)} | new_row]
      end) |> Enum.reverse
      [new_row | new_pixels]
    end) |> Enum.reverse
  end

  # At this point, `palette_map` is a map between pixel values and their index.
  # Now, to place them into an list.
  defp convert_palette_map_to_array(%PNG{palette: palette_map}=image) do
    %PNG{image | palette: palette_array_from_map(palette_map)}
  end

  defp palette_array_from_map(palette_map) do
    Enum.reduce(palette_map, :array.new(Dict.size(palette_map)), fn ({pixel, index}, palette_array) ->
      :array.set(index, pixel, palette_array)
    end)
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
