defmodule Imagineer.Image.PNG.Chunk.Encoders.Background do
  alias Imagineer.Image.PNG

  @color_type_grayscale               0
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_grayscale_with_alpha    4
  @color_type_color_and_alpha         6

  # If there is no background, just don't write anything!
  def encode(%PNG{background: nil}), do: nil

  # If we are paletting, find that index!
  def encode(%PNG{color_type: @color_type_palette_and_color}=image) do
    :array.to_list(image.palette)
    |> Enum.find_index(fn (color) -> color == image.background end)
    |> encoded_background_color(image)
  end

  # Write, the pixel, write write, the pixel!
  def encode(%PNG{background: background}=image) do
    encoded_background_color(background, image)
  end

  defp encoded_background_color(background_color, image) do
    case {image.color_type, background_color} do
      {@color_type_grayscale, {gray}} ->
        <<gray::integer-size(16)>>
      {@color_type_color, {red, green, blue}} ->
        <<red::size(16), green::size(16), blue::size(16)>>
      {@color_type_palette_and_color, index} when is_integer(index) ->
        <<index::integer-size(8)>>
      {@color_type_grayscale_with_alpha, {gray}} ->
        <<gray::integer-size(16)>>
      {@color_type_color_and_alpha, {red, green, blue}} ->
        <<red::size(16), green::size(16), blue::size(16)>>
      {color_type, background_color} ->
        raise "Invalid background color #{inspect(background_color)} for color type #{inspect color_type}"
    end
  end
end
