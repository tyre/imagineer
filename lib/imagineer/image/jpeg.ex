defmodule Imagineer.Image.JPEG do
  defstruct alias: nil, mime_type: "image/jpeg", width: nil, height: nil,
            uri: nil, attributes: %{}, content: <<>>, raw: nil, comment: nil,
            version: nil, density_units: nil, x_density: nil, y_density: nil,
            thumbnail: nil, bit_depth: nil, quality: nil, quantization_tables: []

  alias Imagineer.Image.JPEG

  require Logger

  def process(raw_image_data) do
    JPEG.Markers.decode(raw_image_data, %JPEG{raw: raw_image_data})
  end
end


  # # APP2 is used by Exif to store FlashPix extention information. This metadata
  # # can be used by some cameras to, for example, store a preview of the image.
  # # We don't care about this (yet.)
  # # https://en.wikipedia.org/wiki/Exchangeable_image_file_format#FlashPix_extensions
  # defp process(image, <<@app2, rest::binary>>) do
  #   IO.puts "Got APP2, skipping"
  #   {_flash_pix_data, rest} = marker_content(rest)
  #   process(image, rest)
  # end

  # # APP14 is used by Adobe. We don't yet care about this.
  # # > The "Adobe" APP14 segment stores image encoding information for DCT filters.
  # # > This segment may be copied or deleted as a block using the Extra "Adobe"
  # # > tag, but note that it is not deleted by default when deleting all metadata
  # # > because it may affect the appearance of the image.
  # # http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/JPEG.html#Adobe
  # defp process(image, <<@app14, rest::binary>>) do
  #   IO.puts "Got APP14, skipping"
  #   {_adobe_dct_filters, rest} = marker_content(rest)
  #   process(image, rest)
  # end

  # defp process(%JPEG{}=image, <<@define_quantization_table, rest::binary>>) do
  #   {marker_content, rest} = marker_content(rest)
  #   process_quantization_table(image, marker_content)
  #   |> process(rest)
  # end

  # # Adobe Photoshop uses the APP13 segment for storing non-graphic information,
  # # such as layers, paths, IPTC data, etc. We don't care about this stuff
  # defp process(image, <<@app13, rest::binary>>) do
  #   IO.puts "Got APP13, skipping"
  #   {_photoshop_stuff, rest} = marker_content(rest)
  #   process(image, rest)
  # end

  # defp process(image, <<@comment, rest::binary>>) do
  #   {marker_content, rest} = marker_content(rest)
  #   %JPEG{image | comment: marker_content}
  #   |> process(rest)
  # end

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


  # If the restart interval has zero values, we don't need to do anything
  # defp process(image, <<@define_restart_interval, _length::binary-size(2), <<0, 0>>, rest::binary>>) do
  #   process(image, rest)
  # end
