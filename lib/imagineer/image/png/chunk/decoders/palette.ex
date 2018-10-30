defmodule Imagineer.Image.PNG.Chunk.Decoders.Palette do
  alias Imagineer.Image.PNG

  def decode(content, %PNG{} = image) do
    %PNG{image | palette: read_palette(content)}
  end

  # We store as an array because we need to access by index
  defp read_palette(content) do
    read_palette(content, [])
    |> :array.from_list()
  end

  # In the base case, we have a list of palette colors
  defp read_palette(<<>>, palette) do
    Enum.reverse(palette)
  end

  defp read_palette(<<red::size(8), green::size(8), blue::size(8), more_palette::binary>>, acc) do
    read_palette(more_palette, [{red, green, blue} | acc])
  end
end
