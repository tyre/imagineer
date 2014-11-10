defmodule Imagineer.Image.JPG do
  alias Imagineer.Image

  @start_of_image   <<255::size(8), 216::size(8)>>
  @end_of_image     <<255::size(8), 217::size(8)>>
  @app0             <<255::size(8), 224::size(8)>>
  @jfif_identifier  <<74::size(8), 70::size(8), 73::size(8), 70::size(8)>>

  def process(%Image{format: :jpg}=image) do
    IO.puts "JPEG!!"
    <<@start_of_image, rest::binary>>=image.raw
    process_raw(rest)
    image
  end

  def process_raw(<<@app0, len16::size(8), len1::size(8), rest::binary>>) do
    IO.puts "Got some app0 up in here!"
    content_length = 16 * len16 + len1
    <<content::binary-size(content_length), rest::binary>> = rest
    process_app0(content)
  end

  defp process_app0(<<@jfif_identifier, version_major::size(8),
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
      thumbnail_data_size: thumbnail_data_size
    }
  end
end
