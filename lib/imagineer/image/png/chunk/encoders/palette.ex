defmodule Imagineer.Image.PNG.Chunk.Encoders.Palette do
  alias Imagineer.Image.PNG

  def encode(%PNG{palette: palette}) when is_list(palette) do
    build_palette(palette)
  end

  def encode(%PNG{palette: palette}) do
    build_palette(:array.to_list(palette))
  end

  # if the palette is empty, skip the chunk
  defp build_palette([]), do: nil

  defp build_palette(palette) do
    encode_palette(palette, <<>>)
  end

  defp encode_palette([], encoded_palette) do
    encoded_palette
  end

  defp encode_palette([{red, green, blue} | more_palette], encoded_palette) do
    new_encoded_palette = <<encoded_palette::binary, red::8, green::8, blue::8>>
    encode_palette(more_palette, new_encoded_palette)
  end
end
