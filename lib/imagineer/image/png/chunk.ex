defmodule Imagineer.Image.PNG.Chunk do
  require Logger
  alias Imagineer.Image.PNG.Chunk

  # Required headers
  @ihdr_header <<?I, ?H, ?D, ?R>>
  @plte_header <<?P, ?L, ?T, ?E>>
  @idat_header <<?I, ?D, ?A, ?T>>
  @iend_header <<?I, ?E, ?N, ?D>>

  # Auxillary headers
  @bkgd_header <<?b, ?K, ?G, ?D>>
  @iccp_header <<?i, ?C, ?C, ?P>>
  @phys_header <<?p, ?H, ?Y, ?s>>
  @itxt_header <<?i, ?T, ?X, ?t>>
  @gama_header <<?g, ?A, ?M, ?A>>
  @trns_header <<?t, ?R, ?N, ?S>>

  def decode(header, content, crc, image) do
    verify_crc!(header, content, crc)
    decode_chunk(header, content, image)
  end

  defp decode_chunk(@ihdr_header, content, image),
    do: Chunk.Header.decode(content, image)
  defp decode_chunk(@gama_header, content, image),
    do: Chunk.Gamma.decode(content, image)
  defp decode_chunk(@phys_header, content, image),
    do: Chunk.PhysicalPixelDimensions.decode(content, image)
  defp decode_chunk(@plte_header, content, image),
    do: Chunk.Palette.decode(content, image)
  defp decode_chunk(@idat_header, content, image),
    do: Chunk.DataContent.decode(content, image)
  defp decode_chunk(@bkgd_header, content, image),
    do: Chunk.Background.decode(content, image)

  defp decode_chunk(unknown_header, _content, image) do
    Logger.debug("Skipping unknown header #{unknown_header}")
    image
  end

  defp verify_crc!(header, content, valid_crc) do
    unless :erlang.crc32(header <> content) == valid_crc do
      raise("CRC for #{header} is invalid")
    end
  end
end
