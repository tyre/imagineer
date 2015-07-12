defmodule Imagineer.Image.JPG do
  require Logger
  alias Imagineer.Image.JPG
  defstruct alias: nil,
            width: nil,
            height: nil,
            bit_depth: nil,
            color_type: nil,
            color_format: nil,
            uri: nil,
            format: :jpg,
            attributes: %{},
            data_content: <<>>,
            raw: nil,
            comment: "",
            mask: nil,
            compression: :dct,
            decompressed_data: nil,
            unfiltered_rows: nil,
            scanlines: [],
            filter_method: nil,
            interface_method: nil,
            gamma: nil,
            palette: [],
            pixels: [],
            components: nil

  @behaviour Imagineer.Image

  @moduledoc """
  YCbCr
    - Y: luminance (the average of R, G, B values)
    - Cb: chromatic blue
    - Cr: chromatic red
  """

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

  @comment             <<255::size(8), 254::size(8)>>

  @start_of_baseline_frame   <<255::size(8), 192::size(8)>>
  @start_of_progressive_frame   <<255::size(8), 194::size(8)>>
  @define_huffman_table      <<255::size(8), 196::size(8)>>
  @define_quantization_table <<255::size(8), 219::size(8)>>
  @start_of_scan             <<255::size(8), 218::size(8)>>

  @restart_interval   <<255::size(8), 221::size(8)>>
  @restart0           <<255::size(8), 208::size(8)>>
  @restart1           <<255::size(8), 209::size(8)>>
  @restart2           <<255::size(8), 210::size(8)>>
  @restart3           <<255::size(8), 211::size(8)>>
  @restart4           <<255::size(8), 212::size(8)>>
  @restart5           <<255::size(8), 213::size(8)>>
  @restart6           <<255::size(8), 214::size(8)>>
  @restart7           <<255::size(8), 215::size(8)>>

  @padding            <<0::size(8), 4::size(8)>>

  @jfif_identifier  <<74::size(8), 70::size(8), 73::size(8), 70::size(8)>>

  ## Colors
  # used to calculate
  @kr 0.299
  @kb 0.114

  def process(<<@start_of_image, rest::binary>>=raw) do
    IO.puts "START"
    process(rest, %JPG{raw: raw})
  end

  def process(<<@start_of_image, rest::binary>>, %JPG{}=image) do
    process(rest, image)
  end

  def process(<<@start_of_baseline_frame, rest::binary>>, image) do
    IO.puts "BASELINE"
    {content, rest} = marker_content(rest)
    image = process_start_of_frame(content, image)
    process(rest, image)
  end

  def process(<<@start_of_progressive_frame, rest::binary>>, image) do
    IO.puts "PROGRESSIVE"
    {content, rest} = marker_content(rest)
    image = process_start_of_frame(content, image)
    process(rest, image)
  end

  def process(<<@app0, rest::binary>>, image) do
    IO.puts "APP0"
    Logger.debug("APP0")
    {marker_content, rest} = marker_content(rest)
    image = process_app0(image, marker_content)
    process(rest, image)
  end

  def process(<<@define_quantization_table, rest::binary>>, %JPG{}=image) do
    IO.puts "DQT"
    Logger.debug("DQT...skipping...")
    {marker_content, rest} = marker_content(rest)
    image = process_quantization_table(image, marker_content)
    process(rest, image)
  end

  def process(<<@app13, rest::binary>>, image) do
    IO.puts "APP13"
    Logger.debug("APP13!")
    process(process_app13(rest, image), image)
  end

  def process(<<@comment, rest::binary>>, image) do
    IO.puts "COMMENT"
    {marker_content, rest} = marker_content(rest)
    image = %JPG{image | comment: image.comment <> marker_content}
    process(rest, image)
  end

  def process(<<@padding, rest::binary>>, image) do
    IO.puts "PADDING"
    {marker_content, rest} = marker_content(rest)
    process(rest, image)
  end

  def process(<<@define_huffman_table, rest::binary>>, image) do
    IO.puts "DFT"
    {marker_content, rest} = marker_content(rest)
    Logger.debug(marker_content, raw: true)
    image = process_huffman_table(marker_content, image)
    process(rest, image)
  end

  def process(<<@restart_interval, marker::size(32), rest::binary>>, image) do
    IO.puts "RESTART INTERVAL"
    # IO.puts marker
    process(rest, image)
  end

  def process(<<@restart0, rest::binary>>, image) do
    IO.puts "RESTART0"
    process(rest, image)
  end

  def process(<<@restart1, rest::binary>>, image) do
    IO.puts "RESTART1"
    process(rest, image)
  end

  def process(<<@restart2, rest::binary>>, image) do
    IO.puts "RESTART2"
    process(rest, image)
  end

  def process(<<@restart3, rest::binary>>, image) do
    IO.puts "RESTART3"
    process(rest, image)
  end

  def process(<<@restart4, rest::binary>>, image) do
    IO.puts "RESTART4"
    process(rest, image)
  end

  def process(<<@restart5, rest::binary>>, image) do
    IO.puts "RESTART5"
    process(rest, image)
  end

  def process(<<@restart6, rest::binary>>, image) do
    IO.puts "RESTART6"
    process(rest, image)
  end

  def process(<<@restart7, rest::binary>>, image) do
    IO.puts "RESTART7"
    process(rest, image)
  end

  def process(<<@start_of_scan, rest::binary>>, image) do
    IO.puts "START SCAN"
    {marker_content, rest} = marker_content(rest)
    process_start_of_scan(marker_content, image)
    process(rest, image)
  end

  def process(<<@end_of_image>>, image) do
    IO.puts "END"
    image
  end

  def process(<<255::size(8), marker::size(8), rest::binary>>, image) do
    IO.puts "UNKNOWN"
    IO.puts marker
    Logger.debug("Skipping unknown marker #{marker}")
    # {marker_content, rest} = marker_content(rest)
    process(rest, image)
  end

  # From [Wikipedia](http://en.wikibooks.org/wiki/JPEG_-_Idea_and_Practice/The_header_part#The_Quantization_table_segment_DQT):
  # > A quantization table is specified in a DQT segment. A DQT segment begins with
  # > the marker DQT = 219 and the length, which is (0, 67). Then comes a byte the
  # > first half of which here is 0, meaning that the table consists of bytes
  # > (8 bit numbers - for the extended mode it is 1, meaning that the table consists
  # > of words, 16 bit numbers), and the last half of which is the destination
  # > identifier of the table (0-3), for instance 0 for the Y component and 1 for the
  # > colour components. Next follow the 64 numbers of the table (bytes).
  defp process_quantization_table(image, content) do
    IO.puts "PQT"
    image
  end

  # The leading byte tells us the number of bits to a color value. 8 is normal (
  # i.e. one byte.) 12 is extended mode.
  defp process_start_of_frame(
    <<8, height::size(2)-unit(8), width::size(2)-unit(8), _num_components::size(8),
    components::binary>>,
    image)
  do
    components = parse_components(components)
    %JPG{image | height: height, width: width, components: components}
  end

  defp process_start_of_scan(<<num_components::size(8), sos_rest::binary>>, image) do
    IO.puts "SoS"
    # <<3, 1, 0, 2, 17, 3, 17, 0, 63, 0>>
    component_size = num_components * 16
    <<components::size(component_size), spectral_start::size(8), spectral_end::size(8), pos_high::size(4), pos_low::size(4)>> = sos_rest
    IO.puts spectral_start
    IO.puts spectral_end
    # components = parse_components(components)
    # %JPG{image | components: components}
  end

  defp parse_components(components) do
    parse_components(components, [])
  end

  defp parse_components(<<>>, parsed) do
    Enum.reverse parsed
  end

  defp parse_components(
    <<id::size(8), hi::size(4), vi::size(4),
    quantization_table_destination_selector::size(8), rest::binary>>,
    parsed)
  do
    parsed_component = {id, hi, vi, quantization_table_destination_selector}
    parse_components(rest,[parsed_component | parsed])
  end

## DC Y Component
  defp process_huffman_table(<<0::size(4), 0::size(4), rest::binary>>, image) do
    image
  end

## DC Color Component
  defp process_huffman_table(<<0::size(4), 1::size(4), rest::binary>>, image) do
    image
  end

## AC Y Component
  defp process_huffman_table(<<1::size(4), 0::size(4), rest::binary>>, image) do
    image
  end

## DC Color component
  defp process_huffman_table(<<1::size(4), 1::size(4), rest::binary>>, image) do
    image
  end

  defp process_app13(rest, image) do
    Logger.debug("skipping APP13")
    {_marker_content, rest} = marker_content(rest)
    rest
  end

  defp process_app0(image, <<@jfif_identifier, version_major::size(8),
                      version_minor::size(8), density_units::size(8),
                      x_density::size(16), y_density::size(16),
                      thumbnail_width::size(8), thumbnail_height::size(8),
                      rest::binary>>) do
    thumbnail_data_size = 3 * thumbnail_width * thumbnail_height
    <<thumbnail_data::binary-size(thumbnail_data_size), rest::binary>> = rest
    image
  end

  # The content length of any marker is (the first length byte * 256) + the
  # second byte. Since this includes the length bytes themselves, we subtract
  # two to get the length of the actual content
  defp marker_content(<<total_length::size(2)-unit(8), rest::binary>>) do
    content_length = total_length - 2
    IO.puts "CONTENT LENGTH"
    IO.puts content_length
    <<content::binary-size(content_length), rest::binary>> = rest
    {content, rest}
  end

end
