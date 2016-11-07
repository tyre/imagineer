defmodule Imagineer.Image.JPEG.Markers.Decoders.StartOfScan do
  require Logger

  @end_of_image <<255::size(8), 217::size(8)>>

  def decode(<<
      number_of_components::integer-size(8),
      component_data::binary
    >>,
    image,
    rest_of_content)
  do
    scan_data = extract_components(number_of_components, component_data, image)
    |> parse_scan_data(rest_of_content)
    new_image = %{image |
        attributes: %{
          scan_data: scan_data
        }
      }
    {@end_of_image, new_image}
  end

  defp extract_components(number_of_components, component_data, image) do
    Logger.debug("\tParsing #{number_of_components} components")
    Logger.debug("\tComponent data:")
    Logger.debug("\t\t#{inspect(component_data)}")
    %{image |
        attributes: %{ image.attributes |
          components: parse_components(number_of_components, component_data, [])
        }
      }
  end

  defp parse_components(0, _rest, components) do
    Enum.reverse(components)
  end

  defp parse_components(number_of_components,
    <<
      component_id::integer-size(8),
      ac_table::integer-size(4),
      dc_table::integer-size(4),
      rest::binary
    >>,
    components)
  do
    Logger.debug("\t\t\tcomponent #{length(components) + 1}: #{inspect {component_id, ac_table, dc_table}}")
    parse_components(
      number_of_components - 1,
      rest,
      [{component_id, ac_table, dc_table} | components]
    )
  end

  defp parse_components(number_of_components, another_bin, components) do
    Logger.debug("UH OH!")
    Logger.debug("\t#{number_of_components} components left to parse")
    Logger.debug("\tanother_bin: #{inspect(another_bin)}")
    Logger.debug("\tcomponents: #{inspect(components)}")
  end

  defp parse_scan_data(image, rest_of_content) do
    {scan_data, rest_of_content} = reduce_scan_data(rest_of_content)
  end

  defp reduce_scan_data(@end_of_image), do: {<<>>, <<>>}
  defp reduce_scan_data(<<@end_of_image, binary>>), do: {<<>>, binary}

  defp reduce_scan_data(<<255, 255, rest::binary>>) do
    {new_data, rest_data} = reduce_scan_data(rest)
    {<<255>> <> new_data, rest_data}
  end

  defp reduce_scan_data(<<a_byte::binary-size(1), rest::binary>>) do
    {new_data, rest_data} = reduce_scan_data(rest)
    {a_byte <> new_data, rest_data}
  end
end
