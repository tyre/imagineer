defmodule Imagineer.Image.JPEG.Markers.Decoders.StartOfScan do
  require Logger

  @end_of_image <<255::size(8), 217::size(8)>>

  def decode(<<
      _number_of_color_components::integer-size(8),
      component_data::binary
    >>,
    image,
    rest_of_content)
  do
    scan_data = extract_components(component_data, image)
    |> parse_scan_data(rest_of_content)
    %{image |
        attributes: %{
          scan_data: scan_data
        }
      }
  end

  defp extract_components(component_data, image) do
    %{image |
        attributes: %{ image.attributes |
          components: parse_components(component_data, [])
        }
      }
  end

  defp parse_components(<<>>, components) do
    Enum.reverse(components)
  end

  defp parse_components(<<
                          component_id::integer-size(8),
                          ac_table::integer-size(4),
                          dc_table::integer-size(4)
    >>,
    components)
  do
    [{component_id, ac_table, dc_table} | components]
  end

  defp parse_scan_data(image, rest_of_content) do
    {scan_data, rest_of_content} = reduce_scan_data(rest_of_content)
  end

  defp reduce_scan_data(@end_of_image), do: <<>>
  defp reduce_scan_data(<<@end_of_image, _binary>>), do: <<>>

  defp reduce_scan_data(<<255, 255, rest::binary>>) do
    <<255>> <> reduce_scan_data(rest)
  end

  defp reduce_scan_data(<<a_byte::binary-size(1), rest::binary>>) do
    a_byte <> reduce_scan_data(rest)
  end
end
