defmodule Imagineer.Image.JPEG.Markers.Decoders.APP0 do
  alias Imagineer.Image.JPEG

  @jfif_identifier  <<74::size(8), 70::size(8), 73::size(8), 70::size(8), 0::8>>

  def decode(<<@jfif_identifier,
                version_major::size(8),
                version_minor::size(8),
                density_units::size(8),
                x_density::size(16),
                y_density::size(16),
                thumbnail_width::size(8),
                thumbnail_height::size(8),
                rest::binary>>,
             image) do
    thumbnail_data_size = 3 * thumbnail_width * thumbnail_height
    <<thumbnail_data::binary-size(thumbnail_data_size), _rest::binary>> = rest
    %JPEG{
      image |
      version: {version_major, version_minor},
      density_units: density_units,
      x_density: x_density,
      y_density: y_density,
      thumbnail: %{
        size: thumbnail_data_size,
        content: thumbnail_data,
        height: thumbnail_height,
        width: thumbnail_width
      }
    }
  end
end
