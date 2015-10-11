defmodule Imagineer.Image.PNG do
  require Logger
  alias Imagineer.Image.PNG
  import Imagineer.Image.PNG.Helpers

  @mime_type "image/png"

  defstruct alias: nil,
            width: nil,
            height: nil,
            bit_depth: nil,
            color_type: nil,
            color_format: nil,
            uri: nil,
            format: :png,
            attributes: %{},
            data_content: <<>>,
            raw: nil,
            comment: nil,
            mask: nil,
            compression: :zlib,
            decompressed_data: nil,
            unfiltered_rows: nil,
            scanlines: [],
            filter_method: nil,
            interlace_method: nil,
            gamma: nil,
            palette: [],
            pixels: [],
            mime_type: @mime_type

  @behaviour Imagineer.Image

  @png_signature <<137::size(8), ?P, ?N, ?G, ?\r,  ?\n, 26::size(8), ?\n>>

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

  # Compression
  @zlib 0

  # Filter Methods
  @filter_five_basics 0

  # Filter Types
  # http://www.w3.org/TR/PNG-Filters.html
  @filter_0 :none
  @filter_1 :sub
  @filter_2 :up
  @filter_3 :average
  @filter_4 :paeth

  # Color Types
  # Color type is a single-byte integer that describes the interpretation of the
  # image data. Color type codes represent sums of the following values:
  #   - 1 (palette used)
  #   - 2 (color used)
  #   - 4 (alpha channel used)
  # Valid values are 0, 2, 3, 4, and 6.
  @color_type_raw                     0
  @color_type_palette                 1
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_alpha                   4
  @color_type_palette_color_and_alpha 6

  def process(<<@png_signature, rest::binary>>=raw) do
    process(rest, %PNG{raw: raw})
  end

  def process(<<@png_signature, rest::binary>>, %PNG{}=image) do
    process(rest, image)
  end

  # Processes the "IHDR" chunk
  def process(<<content_length::size(32), @ihdr_header, content::binary-size(content_length), _crc::size(32), rest::binary>>, %PNG{} = image) do
    <<width::integer-size(32),
      height::integer-size(32), bit_depth::integer,
      color_type::integer, compression::integer, filter_method::integer,
      interlace_method::integer>> = content

    image = %PNG{
      image |
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_format: color_format(color_type, bit_depth),
      color_type: color_type,
      compression: compression_format(compression),
      filter_method: filter_method(filter_method),
      interlace_method: interlace_method
    }
    process(rest, image)
  end

  # Process "PLTE" chunk
  def process(<<content_length::integer-size(32), @plte_header, content::binary-size(content_length), _crc::size(32), rest::binary >>,%PNG{}=image) do
    image = %PNG{ image | palette: read_palette(content)}
    process(rest, image)
  end

  # Process "pHYs" chunk
  def process(<<_content_length::integer-size(32), @phys_header,
    x_pixels_per_unit::integer-size(32), y_pixels_per_unit::integer-size(32),
    _unit::binary-size(1), _crc::size(32), rest::binary >>, %PNG{}=image) do
    pixel_dimensions = {
      x_pixels_per_unit,
      y_pixels_per_unit,
      :meter}
    image = %PNG{ image | attributes: set_attribute(image, :pixel_dimensions, pixel_dimensions)}
    process(rest, image)
  end

  # Process the "IDAT" chunk
  # There can be multiple IDAT chunks to allow the encoding system to control
  # memory consumption. Append the content
  def process(<<content_length::integer-size(32), @idat_header, data_content::binary-size(content_length), _crc::size(32), rest::binary >>, image) do
    new_content = image.data_content <> data_content
    process(rest, Map.put(image, :data_content, new_content))
  end

  # Process the "IEND" chunk
  # The end of the PNG
  def process(<<_length::size(32), @iend_header, _rest::binary>>, %PNG{}=image) do
    PNG.DataContent.process(image)
  end

  # Process the auxillary "bKGD" chunk

  def process(
    <<_content_length::size(32), @bkgd_header, gray::size(16), _crc::size(32), rest::binary>>,
    %PNG{color_type: @color_type_raw}=image)
  do
    process_with_background_color(image, gray, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, red::size(16), green::size(16), blue::size(16), _crc::size(32), rest::binary>>,
    %PNG{color_type: @color_type_color}=image)
  do
    process_with_background_color(image, {red, green, blue}, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, index::size(8), _crc::size(32), rest::binary>>,
    %PNG{color_type: @color_type_palette_and_color}=image)
  do
    process_with_background_color(image, elem(image.palatte, index), rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, gray::size(16), _crc::size(32), rest::binary>>,
    %PNG{color_type: @color_type_alpha}=image)
  do
    process_with_background_color(image, gray, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, red::size(16), green::size(16), blue::size(16), _crc::size(32), rest::binary>>,
    %PNG{color_type: @color_type_palette_color_and_alpha}=image)
  do
    process_with_background_color(image, {red, green, blue}, rest)
  end

  # Process the auxillary "gAMA" chunk
  def process(
    <<_content_length::size(32), @gama_header, gamma::integer-size(32), _crc::size(32), rest::binary>>,
    %PNG{}=image)
  do
    process(rest, %PNG{image| gamma: gamma/100_000})
  end

  # Process the auxillary "iTXt" chunk
  def process(<<content_length::size(32), @itxt_header,  content::binary-size(content_length), _crc::size(32), rest::binary>>, %PNG{}=image) do
    image = process_text_chunk(image, content)
    process(rest, image)
  end

  # For headers that we don't understand, skip them
  def process(<<content_length::size(32), header::binary-size(4),
      _content::binary-size(content_length), _crc::size(32), rest::binary>>,
      %PNG{}=image) do
    Logger.debug("Skipping unknown header #{header}")
    process(rest, image)
  end

  defp process_with_background_color(background_color, image, rest) do
    image = %PNG{ image | attributes: set_attribute(image, :background_color, background_color)}
    process(rest, image)
  end

  def to_binary(%PNG{}=png) do
    to_binary(<<@png_signature>>, png)
  end

  def to_binary(bin, png) do
    write_header(bin, png)
    |> write_palette(png)
    # |> write_data_content(png)
  end

  defp write_header(bin, png) do
    encoded_compression_format = encoded_compression_format(png.compression)
    encoded_filter_method = encoded_filter_method(png.filter_method)

    bin <> make_chunk(@ihdr_header, <<
      png.width::integer-size(32),
      png.height::integer-size(32),
      png.bit_depth::integer,
      png.color_type::integer,
      encoded_compression_format::integer,
      encoded_filter_method::integer,
      png.interlace_method::integer
    >>)
  end

  # if the palette is empty, skip the chunk
  defp write_palette(bin, %PNG{palette: []}) do
    bin
  end

  defp write_palette(bin, %PNG{}=png) do
    bin <> make_chunk(@plte_header, encode_palette(png.palette, <<>>))
  end

  defp encode_palette([], encoded_palette) do
    encoded_palette
  end

  defp encode_palette([{red, green, blue} | more_palette], encoded_palette) do
    new_encoded_palette = <<encoded_palette, red::size(8), green::size(8), blue::size(8)>>
    encode_palette(more_palette, new_encoded_palette)
  end

  # Private helper functions

  defp set_attribute(%PNG{} = image, attribute, value) do
    Map.put image.attributes, attribute, value
  end

  defp make_chunk(header, chunk_content) do
    content_length = byte_size(chunk_content)
    cyclic_redundency_check = :erlang.crc32(chunk_content)
    <<
      content_length::integer-unit(1)-size(32),
      header::binary-size(4),
      chunk_content::binary,
      cyclic_redundency_check::size(32)
    >>
  end

  # Check the compression byte. Purposefully raise if not zlib
  defp compression_format(@zlib), do: :zlib
  defp encoded_compression_format(:zlib), do: @zlib

  # Check for the filter method. Purposefully raise if not the only one defined
  defp filter_method(@filter_five_basics), do: :five_basics
  defp encoded_filter_method(:five_basics), do: @filter_five_basics


  # We store as an array because we need to access by index
  defp read_palette(content) do
    read_palette(content, [])
    |> :array.from_list
  end

  # In the base case, we have a list of palette colors
  defp read_palette(<<>>, palette) do
    Enum.reverse palette
  end

  defp read_palette(<<red::size(8), green::size(8), blue::size(8), more_palette::binary>>, acc) do
    read_palette(more_palette, [{red, green, blue}| acc])
  end

  defp process_text_chunk(image, content) do
    case parse_text_pair(content, <<>>) do
      {key, value} ->
        set_text_attribute(image, key, value)
      false ->
        image
    end
  end

  defp parse_text_pair(<<0, value::binary>>, key) do
    {String.to_atom(key), strip_null_bytes(value)}
  end

  defp parse_text_pair(<<key_byte::binary-size(1), rest::binary>>, key) do
    parse_text_pair(rest, key <> key_byte)
  end

  defp parse_text_pair(<<>>, _key) do
    false
  end

  # Strip all leading null bytes (<<0>>) from the text
  defp strip_null_bytes(<<0, rest::binary>>) do
    strip_null_bytes rest
  end

  defp strip_null_bytes(content) do
    content
  end

  # Sets the attribute relevant to whatever is held in the text chunk,
  # returns the image
  defp set_text_attribute(image, key, value) do
    case key do
      :Comment ->
        %PNG{image | comment: value}
      _ ->
        %PNG{image | attributes: set_attribute(image, key, value)}
    end
  end

end
