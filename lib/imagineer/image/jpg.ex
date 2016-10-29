defmodule Imagineer.Image.JPG do
  defstruct alias: nil, mime_type: "image/jpeg", width: nil, height: nil,
            uri: nil, attributes: %{}, content: <<>>, raw: nil, comment: nil,
            version: nil, density_units: nil, x_density: nil, y_density: nil,
            thumbnail: nil

  alias Imagineer.Image.JPG

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
  @define_huffman_table      <<255::size(8), 196::size(8)>>
  @define_quantization_table <<255::size(8), 219::size(8)>>
  @define_restart_interval   <<255::size(8), 221::size(8)>>
  @start_of_scan             <<255::size(8), 218::size(8)>>

  @jfif_identifier  <<74::size(8), 70::size(8), 73::size(8), 70::size(8)>>

  def process(<<@start_of_image, rest::binary>>=raw) do
    process %JPG{raw: raw}, rest
  end

  defp process(image, <<@start_of_baseline_frame, rest::binary>>) do
    {baseline_information, rest} =  marker_content(rest)
    image = process_baseline_frame(baseline_information, image)

    IO.puts inspect image
    IO.puts inspect rest
    process(image, rest)
  end

  # A leading 8 means the colors in stored in 8 bit chunks, which is the
  # standard mode. The extended mode does colors in 12 bit chunks.
  defp process_baseline_frame(<<8,
      height::size(16)-integer,
      width::size(16)-integer,
      number_of_components::size(8),
      rest::binary>>,
      image)
  do
    components_size = number_of_components * 3
    <<components::binary-size(components_size), rest::binary>> = rest
    IO.puts("Got some components:: #{byte_size(components)}\n#{inspect components}")
    IO.puts("with this leftover #{rest}")
    %JPG{image | width: width, height: height,
      attributes: Map.merge(image.attributes, %{components: parse_components(components)})
    }
  end

  defp process(image, <<@app0, rest::binary>>) do
    IO.puts "APP0"
    {marker_content, rest} = marker_content(rest)
    process_app0(image, marker_content)
    |> process(rest)
  end

  # APP2 is used by Exif to store FlashPix extention information. This metadata
  # can be used by some cameras to, for example, store a preview of the image.
  # We don't care about this (yet.)
  # https://en.wikipedia.org/wiki/Exchangeable_image_file_format#FlashPix_extensions
  defp process(image, <<@app2, rest::binary>>) do
    IO.puts "Got APP2, skipping"
    {_flash_pix_data, rest} = marker_content(rest)
    process(image, rest)
  end

  # APP14 is used by Adobe. We don't yet care about this.
  # > The "Adobe" APP14 segment stores image encoding information for DCT filters.
  # > This segment may be copied or deleted as a block using the Extra "Adobe"
  # > tag, but note that it is not deleted by default when deleting all metadata
  # > because it may affect the appearance of the image.
  # http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/JPEG.html#Adobe
  defp process(image, <<@app14, rest::binary>>) do
    IO.puts "Got APP14, skipping"
    {_flash_pix_data, rest} = marker_content(rest)
    process(image, rest)
  end

  defp process(%JPG{}=image, <<@define_quantization_table, rest::binary>>) do
    {marker_content, rest} = marker_content(rest)
    process_quantization_table(image, marker_content)
    |> process(rest)
  end

  # Adobe Photoshop uses the APP13 segment for storing non-graphic information,
  # such as layers, paths, IPTC data, etc. We don't care about this stuff
  defp process(image, <<@app13, rest::binary>>) do
    IO.puts "Got APP13, skipping"
    {_photoshop_stuff, rest} = marker_content(rest)
    process(image, rest)
  end

  defp process(image, <<@comment, rest::binary>>) do
    {marker_content, rest} = marker_content(rest)
    %JPG{image | comment: marker_content}
    |> process(rest)
  end

  defp process(image, <<@define_huffman_table, rest::binary>>) do
    IO.puts "Huffman table definition"
    {huffman_content, rest} = marker_content(rest)
    process_huffman_content(huffman_content, image)
    process(image, rest)
  end

  # Usually there are two Huffman table segments in the file for a grey scale
  # picture and four for a colour picture: for each component the DC and the AC
  # numbers are coded differently, and the Y component and the two colour
  # components are coded differently. In a Huffman segment the information (after
  # the marker and the pair of bytes stating the length) is arranged in this way:
  #
  # the first half byte is 0 if the Huffman tables are for DC numbers and 1 if
  # they are for the AC numbers. The next half byte is the Huffman table destination
  # identifier (0 or 1), for instance 0 for the Y component and 1 for the colour
  # components (to be referred to in the scan segment SOS where the Huffman tables
  # are specified).
  # The following sequence of 16 bytes is the list BITS, stating
  # for i = 1, ..., 16 the number of codes of length i. And then comes the list HUFFVAL
  # of Huffman values: for each code length different from zero, there will be
  # just as many values as there are codes of this length. If we call the number
  # of Huffman values nhv, the number of bytes in the segment (including the pair
  # stating the length) is 19 + nhv.

  # we are processing a DC component
  # we are processing a Y component
  # defp process_huffman_content(<<0::4, 0::4, rest::binary>>, image)
  defp process_huffman_content(<<_rest::binary>>, _image)
  do
    IO.puts "TODO: read huffman table"
  end

  defp process(image, <<@end_of_image>>) do
    image
  end

  # If the restart interval has zero values, we don't need to do anything
  defp process(image, <<@define_restart_interval, _length::binary-size(2), <<0, 0>>, rest::binary>>) do
    process(image, rest)
  end

  defp process(image, <<255::size(8), marker::size(8), rest::binary>>) do
    IO.puts "Skipping unknown marker #{marker}"
    {marker_content, rest} = marker_content(rest)
    IO.puts "\tContent: #{inspect marker_content}"
    process image, rest
  end

  # From [Wikipedia](http://en.wikibooks.org/wiki/JPEG_-_Idea_and_Practice/The_header_part#The_Quantization_table_segment_DQT):
  # > A quantization table is specified in a DQT segment. A DQT segment begins with
  # > the marker DQT = 219 and the length, which is (0, 67). Then comes a byte the
  # > first half of which here is 0, meaning that the table consists of bytes
  # > (8 bit numbers - for the extended mode it is 1, meaning that the table consists
  # > of words, 16 bit numbers), and the last half of which is the destination
  # > identifier of the table (0-3), for instance 0 for the Y component and 1 for the
  # > colour components. Next follow the 64 numbers of the table (bytes).
  defp process_quantization_table(image, _content) do
    IO.puts "TODO process_quantization_table"
    image
  end

  defp parse_components(raw) do
    parse_components(raw, [])
  end

  defp parse_components(<<>>, components) do
    Enum.reverse components
  end

  defp parse_components(<<component::binary-size(3), rest::binary>>, components) do
    parse_components(rest, [parse_component(component) | components])
  end

  defp parse_component(<<id::integer-unit(8)-size(1),
    sampling_factor_x::integer-unit(4)-size(1),
    sampling_factor_y::integer-unit(4)-size(1),
    quantization_table_number::integer-unit(8)-size(1)>>)
  do
    %{
      id: id,
      sampling_factor_x: sampling_factor_x,
      sampling_factor_y: sampling_factor_y,
      quantization_table_number: quantization_table_number
    }
  end

  defp process_app0(image, <<@jfif_identifier, version_major::size(8),
                      version_minor::size(8), density_units::size(8),
                      x_density::size(16), y_density::size(16),
                      thumbnail_width::size(8), thumbnail_height::size(8),
                      rest::binary>>) do
    thumbnail_data_size = 3 * thumbnail_width * thumbnail_height
    <<thumbnail_data::binary-size(thumbnail_data_size), _rest::binary>> = rest
    %JPG{
      image |
      version: {version_major, version_minor},
      density_units: density_units,
      x_density:     x_density,
      y_density:     y_density,
      thumbnail: %{
        size: thumbnail_data_size,
        content: thumbnail_data,
        height: thumbnail_height,
        width: thumbnail_width
      }
    }
  end

  # The content length of any marker is (the first length byte * 256) + the
  # second byte. Since this includes the length bytes themselves, we subtract
  # two to get the length of the actual content
  defp marker_content(<<len256::size(8), len1::size(8), rest::binary>>) do
    content_length = len256 * 256 + len1 - 2
    <<content::binary-size(content_length), rest::binary>> = rest
    {content, rest}
  end

end
