defmodule Imagineer.Image.PNG.Chunk.Encoders.Background do
  alias Imagineer.Image.PNG

  @color_type_grayscale 0
  @color_type_color 2
  @color_type_palette_and_color 3
  @color_type_grayscale_with_alpha 4
  @color_type_color_and_alpha 6

  # If there is no background, just don't write anything!
  def encode(%PNG{background: nil}), do: nil

  # If we are paletting, find that index!
  def encode(%PNG{
        color_type: @color_type_palette_and_color,
        palette: palette,
        background: background
      }) do
    background_index =
      :array.to_list(palette)
      |> Enum.find_index(fn color -> color == background end)

    <<background_index::integer-size(8)>>
  end

  def encode(%PNG{color_type: @color_type_grayscale, background: {gray}}) do
    <<gray::integer-size(16)>>
  end

  def encode(%PNG{color_type: @color_type_color, background: {red, green, blue}}) do
    <<red::size(16), green::size(16), blue::size(16)>>
  end

  def encode(%PNG{color_type: @color_type_palette_and_color, background: index})
      when is_integer(index) do
  end

  def encode(%PNG{color_type: @color_type_grayscale_with_alpha, background: {gray}}) do
    <<gray::integer-size(16)>>
  end

  def encode(%PNG{color_type: @color_type_color_and_alpha, background: {red, green, blue}}) do
    <<red::size(16), green::size(16), blue::size(16)>>
  end
end
