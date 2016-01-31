defmodule Imagineer.Image.PNG.Chunk.Decoders.Header do
  alias Imagineer.Image.PNG
  import Imagineer.Image.PNG.Helpers, only: [color_format: 1]

  @filter_five_basics 0
  @zlib 0

  def decode(content, image) do
    <<
      width::integer-size(32),
      height::integer-size(32),
      bit_depth::integer,
      color_type::integer,
      compression::integer,
      filter_method::integer,
      interlace_method::integer
    >> = content

    %PNG{
      image |
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_format: color_format(color_type),
      color_type: color_type,
      compression: compression_format(compression),
      filter_method: filter_method(filter_method),
      interlace_method: interlace_method
    }
  end

  defp filter_method(@filter_five_basics), do: :five_basics

  # Check the compression byte. Purposefully raise if not zlib
  defp compression_format(@zlib), do: :zlib
end
