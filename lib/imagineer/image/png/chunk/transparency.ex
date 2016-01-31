defmodule Imagineer.Image.PNG.Chunk.Transparency do
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

  # If there is no transparency information, nothing to encode
  def encode(%PNG{transparency: nil}), do: nil

  # If there is already an alpha channel, no transparency chunk allowed
  def encode(%PNG{color_type: @color_type_grayscale_with_alpha}), do: nil
  def encode(%PNG{color_type: @color_type_color_and_alpha}), do: nil

  def encode(%PNG{
    color_type: @color_type_grayscale,
    transparency: {gray},
    bit_depth: bit_depth })
  do
    encode_two_byte_channel(<<gray::integer-size(bit_depth)>>)
  end

  def encode(%PNG{
    color_type: @color_type_color,
    transparency: {red, green, blue},
    bit_depth: bit_depth})
  do
    encode_two_byte_channel(<<red::integer-size(bit_depth)>>) <>
    encode_two_byte_channel(<<green::integer-size(bit_depth)>>) <>
    encode_two_byte_channel(<<blue::integer-size(bit_depth)>>)
  end

  def encode(%PNG{color_type: @color_type_palette_and_color, transparency: palette_array}) do
    :array.to_list(palette_array)
    |> Enum.map(fn (palette_index) -> <<palette_index::integer-size(8)>> end)
    |> Enum.join
  end

  defp encode_two_byte_channel(channel) when bit_size(channel) == 16 do
    channel
  end

  defp encode_two_byte_channel(channel) when bit_size(channel) < 16 do
    encode_two_byte_channel(<<channel::bits, 0::1>>)
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
