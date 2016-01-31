defmodule Imagineer.Image.PNG.Chunk.Encoders.Transparency do
  alias Imagineer.Image.PNG

  @color_type_grayscale               0
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_grayscale_with_alpha    4
  @color_type_color_and_alpha         6

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
end
