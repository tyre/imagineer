defmodule Imagineer.Image.PNG.Chunk.Encoders.PhysicalPixelDimensions do
  alias Imagineer.Image.PNG

  def encode(%PNG{attributes: %{pixel_dimensions: {x, y, unit}}}) do
    <<
      x::integer-size(32),
      y::integer-size(32),
      encode_physical_unit(unit)::size(1)
    >>
  end

  def encode(%PNG{}) do
    nil
  end

  defp encode_physical_unit(:unknown), do: 0
  defp encode_physical_unit(:meter), do: 1
end
