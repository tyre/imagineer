defmodule Imagineer.Image.PNG.Chunk do
  alias Imagineer.Image.PNG.Chunk
  require Logger
  import Chunk.Helpers

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

  # Required header
  decode_chunk @ihdr_header, with: Chunk.Header
  decode_chunk @plte_header, with: Chunk.Palette
  decode_chunk @idat_header, with: Chunk.DataContent

  # Auxillary headers
  decode_chunk @bkgd_header, with: Chunk.Background
  decode_chunk @phys_header, with: Chunk.PhysicalPixelDimensions
  decode_chunk @itxt_header, with: Chunk.Text
  decode_chunk @gama_header, with: Chunk.Gamma
  decode_chunk @trns_header, with: Chunk.Transparency

  defp decode_chunk(unknown_header, _content, image) do
    Logger.debug("Skipping unknown header #{unknown_header}")
    image
  end

  encode_chunk @trns_header, with: Chunk.Transparency

  def encode({bin, image}, header) do
    encode_chunk(header, bin, image)
  end


  defp verify_crc!(header, content, valid_crc) do
    unless :erlang.crc32(header <> content) == valid_crc do
      raise("CRC for #{header} is invalid")
    end
  end
end
