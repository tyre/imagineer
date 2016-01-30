defmodule Imagineer.Image.PNG do
  alias Imagineer.Image.PNG

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
            interlace_method: 0,
            gamma: nil,
            palette: [],
            pixels: [],
            mime_type: @mime_type,
            background: nil,
            transparency: nil

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
  @trns_header <<?t, ?R, ?N, ?S>>

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
  @color_type_grayscale               0
  @color_type_color                   2
  @color_type_palette_and_color       3
  @color_type_grayscale_with_alpha    4
  @color_type_color_and_alpha         6

  def process(<<@png_signature, rest::binary>>) do
    process(rest, %PNG{})
  end

  # Process the "IEND" chunk
  # The end of the PNG
  def process(<<_length::size(32), @iend_header, _rest::binary>>, %PNG{}=image) do
    PNG.DataContent.process(image)
  end

  def process(<<
      content_length::size(32),
      header::binary-size(4),
      content::binary-size(content_length),
      crc::size(32),
      rest::binary
    >>, %PNG{}=image)
  do
    process(rest, PNG.Chunk.decode(header, content, crc, image))
  end

  def to_binary(%PNG{}=png) do
    to_binary(<<@png_signature>>, png)
  end

  def to_binary(bin, png) do
    processed_png = build_data_content(png)
    write_header(bin, processed_png)
    |> write_gamma(processed_png)
    |> write_palette(processed_png)
    |> write_background(processed_png)
    |> write_data_content(processed_png)
    |> write_end_header
  end

  # If there is no background, just don't write anything!
  defp write_background(bin, %PNG{background: nil}), do: bin

  # If there is no background and we are paletting, find that index!
  defp write_background(bin, %PNG{
    background: background,
    color_type: @color_type_palette_and_color,
    palette: palette}=image)
  do
    background_color = Enum.find_index(palette, background)
    bin <> make_chunk(@bkgd_header,
      encoded_background_color(image, background_color))
  end

  # Write, the pixel, write write, the pixel!
  defp write_background(bin, %PNG{background: background}=image) do
    bin <> make_chunk(@bkgd_header,
      encoded_background_color(image, background))
  end

  defp encoded_background_color(image, background_color) do
    case {image.color_type, background_color} do
      {@color_type_grayscale, {gray}} ->
        <<gray::integer-size(16)>>
      {@color_type_color, {red, green, blue}} ->
        <<red::size(16), green::size(16), blue::size(16)>>
      {@color_type_palette_and_color, index} when is_integer(index) ->
        <<index::integer-size(8)>>
      {@color_type_grayscale_with_alpha, {gray}} ->
        <<gray::integer-size(16)>>
      {@color_type_color_and_alpha, {red, green, blue}} ->
        <<red::size(16), green::size(16), blue::size(16)>>
      {color_type, background_color} ->
        raise "Invalid background color #{inspect(background_color)} for color type #{inspect color_type}"
    end
  end

  defp write_gamma(bin, %PNG{gamma: nil}), do: bin
  defp write_gamma(bin, %PNG{gamma: gamma}) do
    normalized_gamma = round(gamma * 100_000)
    bin <> make_chunk(@gama_header, <<normalized_gamma::integer-size(32)>>)
  end

  defp write_end_header(bin) do
    bin <> make_chunk(@iend_header, <<>>)
  end

  defp write_data_content(bin, %PNG{data_content: data_content}) do
    bin <> make_chunk(@idat_header, data_content)
  end

  def build_data_content(image) do
    PNG.DataContent.encode(image)
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
    new_encoded_palette = <<encoded_palette::binary, red::8, green::8, blue::8>>
    encode_palette(more_palette, new_encoded_palette)
  end

  # Private helper functions

  defp set_attribute(%PNG{} = image, attribute, value) do
    Map.put image.attributes, attribute, value
  end

  defp make_chunk(header, chunk_content) do
    content_length = byte_size(chunk_content)
    cyclic_redundency_check = :erlang.crc32(header <> chunk_content)
    <<
      content_length::integer-unit(1)-size(32),
      header::binary-size(4),
      chunk_content::binary,
      cyclic_redundency_check::size(32)
    >>
  end

  defp encoded_compression_format(:zlib), do: @zlib

  # Check for the filter method. Purposefully raise if not the only one defined
  defp encoded_filter_method(:five_basics), do: @filter_five_basics

end
