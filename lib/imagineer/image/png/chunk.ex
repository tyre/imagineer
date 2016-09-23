defmodule Imagineer.Image.PNG.Chunk do
  alias Imagineer.Image.PNG.Chunk.Encoders
  alias Imagineer.Image.PNG.Chunk.Decoders
  require Logger
  import Imagineer.Image.PNG.Chunk.Helpers

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
    Logger.debug("Decoding #{header} chunk")
    verify_crc!(header, content, crc)
    decode_chunk(header, content, image)
  end

  # Required headers
  decode_chunk @ihdr_header, with: Decoders.Header
  decode_chunk @plte_header, with: Decoders.Palette
  decode_chunk @idat_header, with: Decoders.DataContent
  decode_chunk @iend_header, with: Decoders.End

  # Auxillary headers
  decode_chunk @bkgd_header, with: Decoders.Background
  decode_chunk @phys_header, with: Decoders.PhysicalPixelDimensions
  decode_chunk @itxt_header, with: Decoders.Text
  decode_chunk @gama_header, with: Decoders.Gamma
  decode_chunk @trns_header, with: Decoders.Transparency

  defp decode_chunk(unknown_header, _content, image) do
    Logger.debug("Unknown header #{unknown_header}, skipping")
    image
  end

  def encode({bin, image}, header) do
    encode_chunk(header, bin, image)
  end

  # Required headers
  encode_chunk @ihdr_header, with: Encoders.Header
  encode_chunk @plte_header, with: Encoders.Palette
  encode_chunk @idat_header, with: Encoders.DataContent
  encode_chunk @iend_header, with: Encoders.DataContent

  encode_chunk @trns_header, with: Encoders.Transparency
  encode_chunk @bkgd_header, with: Encoders.Background
  encode_chunk @gama_header, with: Encoders.Gamma

  defp verify_crc!(header, content, valid_crc) do
    unless :erlang.crc32(header <> content) == valid_crc do
      raise("CRC for #{header} is invalid")
    end
  end
end
