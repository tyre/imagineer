defmodule Imagineer.Image.PNG.Chunk.Decoders.Transparency do
  alias Imagineer.Image.PNG

  @color_type_grayscale               0
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_grayscale_with_alpha    4
  @color_type_color_and_alpha         6

  @palette_default_opacity 255 # fully opaque

  def decode(content, %PNG{color_type: color_type}=image) do
    decode_transparency(color_type, content, image)
  end

  defp decode_transparency(@color_type_grayscale_with_alpha, _content, _image) do
    raise("tRNS chunk should not appear for images with alpha channels")
  end

  defp decode_transparency(@color_type_color_and_alpha, _content, _image) do
    raise("tRNS chunk should not appear for images with alpha channels")
  end

  defp decode_transparency(@color_type_grayscale, opacity_bytes, %PNG{bit_depth: bit_depth}=image) do
    <<opacity::size(bit_depth), _rest::bits>> = opacity_bytes
    %PNG{image | transparency: {opacity} }
  end

  defp decode_transparency(@color_type_color, opacity_bytes, %PNG{bit_depth: bit_depth}=image) do
    %PNG{image | transparency: decode_rgb(opacity_bytes, bit_depth) }
  end

  defp decode_transparency(@color_type_palette_and_color, opacity_bytes, %PNG{}=image) do
    %PNG{image | transparency: palette_opacities(opacity_bytes)}
  end

  defp decode_rgb(<<red::binary-size(2), green::binary-size(2), blue::binary-size(2)>>, bit_depth) do
    {
      take_integer(red, bit_depth),
      take_integer(green, bit_depth),
      take_integer(blue, bit_depth)
    }
  end

  defp take_integer(bin, bit_size) do
    <<taken::size(bit_size), _tossed::bits>> = bin
    taken
  end

  defp palette_opacities(opacity_bytes) do
    palette_opacities(opacity_bytes, [])
    |> :array.from_list(@palette_default_opacity)
  end

  defp palette_opacities(<<>>, opacities) do
    Enum.reverse opacities
  end

  defp palette_opacities(<<opacity::size(8), rest::binary>>, opacities) do
    palette_opacities(rest, [opacity | opacities])
  end
end
