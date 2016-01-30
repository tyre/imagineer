defmodule Imagineer.Image.PNG.Chunk.Background do
  alias Imagineer.Image.PNG

  @moduledoc """
    Process the auxillary "bKGD" chunk
  """

  # Color Types
  # Color type is a single-byte integer that describes the interpretation of the
  # image data. Color type codes represent sums of the following values:
  #   - 1 (palette used)
  #   - 2 (color used)
  #   - 4 (alpha channel used)
  # Valid values are 0, 2, 3, 4, and 6.
  @color_type_grayscale               0
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_grayscale_with_alpha    4
  @color_type_color_and_alpha         6

  ## Indexed color has 1 byte containing the index in the palette
  def decode(content, %PNG{color_type: color_type}=image) do
    decode_background(color_type, content, image)
  end

  ## Palette background is the index of a paletted color
  defp decode_background(@color_type_palette_and_color, <<index::size(8)>>, image) do
    %PNG{image | background: {elem(image.palette, index)} }
  end

  ## Grayscale (any bit depth) contains 2 bytes
  defp decode_background(@color_type_grayscale, <<gray::size(16)>>, image) do
    %PNG{image | background: {gray} }
  end

  ## Grayscale with alpha (any bit depth) contains 2 bytes
  defp decode_background(@color_type_grayscale_with_alpha, <<gray::size(16)>>, image) do
    %PNG{image | background: {gray} }
  end

  ## RGB has 3 2-byte colors
  defp decode_background(@color_type_color, <<red::size(16), green::size(16), blue::size(16)>>, image) do
    %PNG{image | background: {red, green, blue}}
  end

  ## RGB with alpha has 3 2-byte colors
  defp decode_background(@color_type_color_and_alpha, <<red::size(16), green::size(16), blue::size(16)>>, image) do
    %PNG{image | background: {red, green, blue}}
  end
end
