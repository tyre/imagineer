defmodule Imagineer.Image.JPG do
  alias Imagineer.Image

  @start_of_image   <<255::size(8), 216::size(8)>>
  @end_of_image     <<255::size(8), 217::size(8)>>

  # Markers
  @app0                 <<255::size(8), 224::size(8)>>
  @app1                 <<255::size(8), 225::size(8)>>
  @app2                 <<255::size(8), 226::size(8)>>
  @app3                 <<255::size(8), 227::size(8)>>
  @app4                 <<255::size(8), 228::size(8)>>
  @app5                 <<255::size(8), 229::size(8)>>
  @app6                 <<255::size(8), 230::size(8)>>
  @app7                 <<255::size(8), 231::size(8)>>
  @app8                 <<255::size(8), 232::size(8)>>
  @app9                 <<255::size(8), 233::size(8)>>
  @app10                <<255::size(8), 234::size(8)>>
  @app11                <<255::size(8), 235::size(8)>>
  @app12                <<255::size(8), 236::size(8)>>
  @app13                <<255::size(8), 237::size(8)>>
  @app14                <<255::size(8), 238::size(8)>>
  @app15                <<255::size(8), 239::size(8)>>

  @define_huffman_table      <<255::size(8), 196::size(8)>>
  @define_quantization_table <<255::size(8), 219::size(8)>>
  @start_of_scan             <<255::size(8), 218::size(8)>>

  @jfif_identifier  <<74::size(8), 70::size(8), 73::size(8), 70::size(8)>>

  def process(%Image{format: :jpg}=image) do
    IO.puts "JPEG!!"
    process image, image.raw
  end

  defp process(image, <<@start_of_image, rest::binary>>) do
    process(image, rest)
  end

  defp process(image, <<@app0, rest::binary>>) do
    IO.puts "APP0"
    {marker_content, rest} = marker_content(rest)
    process_app0(image, marker_content)
    |> process(rest)
  end

  defp process_app0(image, <<@jfif_identifier, version_major::size(8),
                      version_minor::size(8), density_units::size(8),
                      x_density::size(16), y_density::size(16),
                      thumbnail_width::size(8), thumbnail_height::size(8),
                      rest::binary>>) do
    thumbnail_data_size = 3 * thumbnail_width * thumbnail_height
    <<thumbnail_data::binary-size(thumbnail_data_size), rest::binary>> = rest
    IO.puts inspect %{
      version_major: version_major,
      version_minor: version_minor,
      density_units: density_units,
      x_density:     x_density,
      y_density:     y_density,
      thumbnail_data_size: thumbnail_data_size,
      thumbnail_data: thumbnail_data
    }
    image
  end

  defp process(image, <<@define_huffman_table, rest::binary>>) do
    {marker_content, rest} = marker_content(rest)
  end

  defp process(image, <<@end_of_image>>) do
    image
  end

  defp process(image, <<255::size(8), marker::size(8), rest::binary>>) do
    IO.puts "Skipping unknown marker #{marker}"
    {marker_content, rest} = marker_content(rest)
    IO.puts "\tContent: #{inspect marker_content}"
    process image, rest
  end

  # The content length of any marker is (the first length byte * 256) + the
  # second byte. Since this includes the length bytes themselves, we subtract
  # two to get the length of the actual content
  defp marker_content(<<len256::size(8), len1::size(8), rest::binary>>) do
    content_length = len256 * 256 + len1 - 2
    IO.puts("\tContent Length: #{content_length}")
    <<content::binary-size(content_length), rest::binary>> = rest
    {content, rest}
  end

end
