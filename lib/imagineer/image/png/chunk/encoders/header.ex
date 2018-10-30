defmodule Imagineer.Image.PNG.Chunk.Encoders.Header do
  alias Imagineer.Image.PNG

  @zlib 0
  @filter_five_basics 0

  def encode(%PNG{} = image) do
    encoded_compression_format = encoded_compression_format(image.compression)
    encoded_filter_method = encoded_filter_method(image.filter_method)

    <<
      image.width::integer-size(32),
      image.height::integer-size(32),
      image.bit_depth::integer,
      image.color_type::integer,
      encoded_compression_format::integer,
      encoded_filter_method::integer,
      image.interlace_method::integer
    >>
  end

  defp encoded_compression_format(:zlib), do: @zlib

  # Check for the filter method. Purposefully raise if not the only one defined
  defp encoded_filter_method(:five_basics), do: @filter_five_basics
end
