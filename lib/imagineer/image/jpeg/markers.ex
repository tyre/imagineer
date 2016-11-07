defmodule Imagineer.Image.JPEG.Markers do
  alias Imagineer.Image.JPEG
  alias JPEG.Markers.Decoders

  require Logger

  import __MODULE__.Helpers

  @start_of_image <<255, 216>>
  @end_of_image   <<255, 217>>

  @app0  224
  @app1  225
  @app2  226
  @app3  227
  @app4  228
  @app5  229
  @app6  230
  @app7  231
  @app8  232
  @app9  233
  @app10 234
  @app11 235
  @app12 236
  @app13 237
  @app14 238
  @app15 239

  @comment 254

  @start_of_baseline_frame   192
  @define_huffman_table      196
  @define_quantization_table 219
  @define_restart_interval   221
  @start_of_scan             218

  def decode(<<@start_of_image, rest::binary>>, %JPEG{}=image) do
    decode(rest, image)
  end

  def decode(<<@end_of_image, _rest::binary>>, %JPEG{}=image) do
    image
  end

  def decode(raw, %JPEG{}=image) do
    {marker, marker_content, rest_raw} = extract_marker(raw)
    {new_raw, image} = case decode_marker(marker, marker_content, image, rest_raw) do
      %JPEG{}=image -> {rest_raw, image}
      {modified_rest, %JPEG{}=image} when is_bitstring(modified_rest) ->
        {modified_rest, image}
    end
    decode(new_raw, image)
  end

  decode_marker @start_of_baseline_frame, with: Decoders.BaselineFrame
  decode_marker @define_quantization_table, with: Decoders.QuantizationTable
  decode_marker @define_huffman_table, with: Decoders.HuffmanTable
  decode_marker @start_of_scan, with: Decoders.StartOfScan, include_rest: true
  decode_marker @app0, with: Decoders.APP0

  # decode_marker @app1, with: Decoders.APP1
  # decode_marker @app2, with: Decoders.APP2
  # decode_marker @app3, with: Decoders.APP3
  # decode_marker @app4, with: Decoders.APP4
  # decode_marker @app5, with: Decoders.APP5
  # decode_marker @app6, with: Decoders.APP6
  # decode_marker @app7, with: Decoders.APP7
  # decode_marker @app8, with: Decoders.APP8
  # decode_marker @app9, with: Decoders.APP9
  # decode_marker @app10, with: Decoders.APP10
  # decode_marker @app11, with: Decoders.APP11
  decode_marker @app12, with: Decoders.APP12
  # decode_marker @app13, with: Decoders.APP13
  decode_marker @app14, with: Decoders.APP14
  # decode_marker @app15, with: Decoders.APP15

  defp decode_marker(unknown_marker, content, image, _rest) do
    Logger.debug("Unknown marker #{unknown_marker} (length #{Kernel.byte_size(content)}), skipping")
    image
  end

  defp extract_marker(<<255, marker::integer-size(8), rest::binary>>) do
    Logger.debug("Extracting #{marker} content")
    {marker_content, rest_raw} = marker_content(rest)
    {marker, marker_content, rest_raw}
  end

  # The content length of any marker is (the first length byte * 256) + the
  # second byte. Since this includes the length bytes themselves, we subtract
  # two to get the length of the actual content
  defp marker_content(<<len256::size(8), len1::size(8), rest::binary>>) do
    content_length = len256 * 256 + len1 - 2
    Logger.debug("marker length: #{inspect(content_length)}")
    <<content::binary-size(content_length), rest::binary>> = rest
    {content, rest}
  end
end
