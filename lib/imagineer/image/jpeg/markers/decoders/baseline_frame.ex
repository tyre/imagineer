defmodule Imagineer.Image.JPEG.Markers.Decoders.BaselineFrame do
  alias Imagineer.Image.JPEG

  require Logger

  def decode(
    <<bit_depth::size(8),
      height::size(16)-integer,
      width::size(16)-integer,
      number_of_components::size(8),
      components_content::binary>>,
    image)
  do
    components_size = number_of_components * 3
    <<components::binary-size(components_size), _rest::binary>> = components_content
    Logger.debug("\t" <> inspect(parse_components(components)))
    %JPEG{ image |
      width: width,
      height: height,
      bit_depth: bit_depth,
      attributes: Map.merge(image.attributes, %{components: parse_components(components)})
    }
  end

  defp parse_components(raw) do
    parse_components(raw, [])
  end

  defp parse_components(<<>>, components) do
    Enum.reverse components
  end

  defp parse_components(<<component::binary-size(3), rest::binary>>, components) do
    parse_components(rest, [parse_component(component) | components])
  end

  defp parse_component(<<id::integer-unit(8)-size(1),
    sampling_factor_x::integer-unit(4)-size(1),
    sampling_factor_y::integer-unit(4)-size(1),
    quantization_table_number::integer-unit(8)-size(1)>>)
  do
    %{
      id: id,
      sampling_factor_x: sampling_factor_x,
      sampling_factor_y: sampling_factor_y,
      quantization_table_number: quantization_table_number
    }
  end

end
