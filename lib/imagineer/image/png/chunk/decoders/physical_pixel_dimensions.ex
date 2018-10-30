defmodule Imagineer.Image.PNG.Chunk.Decoders.PhysicalPixelDimensions do
  alias Imagineer.Image.PNG

  def decode(content, %PNG{} = image) do
    <<
      x_pixels_per_unit::integer-size(32),
      y_pixels_per_unit::integer-size(32),
      unit::binary-size(1)
    >> = content

    pixel_dimensions = {
      x_pixels_per_unit,
      y_pixels_per_unit,
      physical_unit(unit)
    }

    %PNG{image | attributes: Map.put(image.attributes, :pixel_dimensions, pixel_dimensions)}
  end

  # Physical unit can be 1 (meter) or 0 (unknown).
  # All other values are invalid
  defp physical_unit(<<1>>), do: :meter
  defp physical_unit(<<0>>), do: :unknown
end
