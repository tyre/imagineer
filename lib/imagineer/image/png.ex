defmodule Imagineer.Image.PNG do
  alias Imagineer.Image

  @png_signiture <<137::size(8), 80::size(8), 78::size(8), 71::size(8),
                   13::size(8),  10::size(8), 26::size(8), 10::size(8)>>

  # Required headers
  @ihdr_header <<73::size(8), 72::size(8), 68::size(8), 82::size(8)>>
  @plte_header <<80::size(8), 76::size(8), 84::size(8), 69::size(8)>>
  @idat_header <<73::size(8), 68::size(8), 65::size(8), 84::size(8)>>
  @iend_header <<73::size(8), 69::size(8), 78::size(8), 68::size(8)>>

  # Auxillary headers
  @bkgd_header <<98::size(8), 75::size(8), 82::size(8), 68::size(8)>>
  @iccp_header <<105::size(8), 67::size(8), 67::size(8), 80::size(8)>>
  @phys_header <<112::size(8), 72::size(8), 89::size(8), 115::size(8)>>
  @text_header <<105::size(8), 84::size(8), 88::size(8), 116::size(8)>>

  def process(%Image{format: :png, raw: raw}=image) do
    process(raw, image)
  end

  def process(<<@png_signiture, rest::binary>>, %Image{}=image) do
    process(rest, image)
  end

  # Processes the "IHDR" chunk
  def process(<<content_length::size(32), @ihdr_header, content::binary-size(content_length), _crc::size(32), rest::binary>>, %Image{} = image) do
    <<width::integer-size(32),
      height::integer-size(32), bit_depth::integer,
      color_type::integer, compression::integer, filter_method::integer,
      interface_method::integer>> = content

    attributes = Map.merge image.attributes, %{
      color_type: color_type,
      compression: compression,
      filter_method: filter_method,
      interface_method: interface_method
    }

    image = %Image{ image | attributes: attributes, width: width, height: height, bit_depth: bit_depth, color_format: color_format(color_type, bit_depth) }
    process(rest, image)
  end

  # Process "PLTE" chunk
  def process(<<content_length::integer-size(32), @plte_header, content::binary-size(content_length), _crc::size(32), rest::binary >>,%Image{}=image) do
    image = %Image{ image | attributes: set_attribute(image, :palette, read_pallete(content))}
    process(rest, image)
  end

  # Process "pHYs" chunk
  def process(<<_content_length::integer-size(32), @phys_header,
    x_pixels_per_unit::integer-size(32), y_pixels_per_unit::integer-size(32),
    _unit::binary-size(1), _crc::size(32), rest::binary >>, %Image{}=image) do
    pixel_dimensions = {
      x_pixels_per_unit,
      y_pixels_per_unit,
      :meter}
    image = %Image{ image | attributes: set_attribute(image, :pixel_dimensions, pixel_dimensions)}
    process(rest, image)
  end

  # Process the "IDAT" chunk
  # There can be multiple IDAT chunks to allow the encoding system to control
  # memory consumption. Append the content
  def process(<<content_length::integer-size(32), @idat_header, content::binary-size(content_length), _crc::size(32), rest::binary >>, image) do
    new_content = image.content <> content
    process(rest, Map.put(image, :content, new_content))
  end

  # Process the "IEND" chunk
  # The end of the PNG
  def process(<<_length::size(32), @iend_header, _rest::binary>>, %Image{}=image) do
    image
  end

  # Process the auxillary "bKGD" chunk
  def process(
    <<_content_length::size(32), @bkgd_header, index::size(8), _crc::size(32), rest::binary>>,
    %Image{attributes: %{ color_type: 3} }=image)
  do
    process_with_background_color(image, index, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, gray::size(16), _crc::size(32), rest::binary>>,
    %Image{attributes: %{ color_type: 0}}=image)
  do
    process_with_background_color(image, gray, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, gray::size(16), _crc::size(32), rest::binary>>,
    %Image{attributes: %{ color_type: 4}}=image)
  do
    process_with_background_color(image, gray, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, red::size(16), green::size(16), blue::size(16), _crc::size(32), rest::binary>>,
    %Image{attributes: %{ color_type: 2}}=image)
  do
    process_with_background_color(image, {red, green, blue}, rest)
  end

  def process(
    <<_content_length::size(32), @bkgd_header, red::size(16), green::size(16), blue::size(16), _crc::size(32), rest::binary>>,
    %Image{attributes: %{ color_type: 6}}=image)
  do
    process_with_background_color(image, {red, green, blue}, rest)
  end

  # Process the auxillary "tEXt" chunk
  def process(<<content_length::size(32), @text_header,  content::binary-size(content_length), _crc::size(32), rest::binary>>, %Image{}=image) do
    image = process_text_chunk(image, content)
    process(rest, image)
  end

  # For headers that we don't understand, skip them
  def process(<<content_length::size(32), _header::binary-size(4),
      _content::binary-size(content_length), _crc::size(32), rest::binary>>,
      %Image{}=image) do
    process(rest, image)
  end

  defp process_with_background_color(background_color, image, rest) do
    image = %Image{ image | attributes: set_attribute(image, :background_color, background_color)}
    process(rest, image)
  end

  # Private helper functions

  defp set_attribute(%Image{} = image, attribute, value) do
    Map.put image.attributes, attribute, value
  end

  # Color formats, taking in the color_type and bit_depth
  defp color_format(0, 1) , do: :grayscale1
  defp color_format(0, 2) , do: :grayscale2
  defp color_format(0, 4) , do: :grayscale4
  defp color_format(0, 8) , do: :grayscale8
  defp color_format(0, 16), do: :grayscale16
  defp color_format(2, 8) , do: :rgb8
  defp color_format(2, 16), do: :rgb16
  defp color_format(3, 1) , do: :palette1
  defp color_format(3, 2) , do: :palette2
  defp color_format(3, 4) , do: :palette4
  defp color_format(3, 8) , do: :palette8
  defp color_format(4, 8) , do: :grayscale_alpha8
  defp color_format(4, 16), do: :grayscale_alpha16
  defp color_format(6, 8) , do: :rgb_alpha8
  defp color_format(6, 16), do: :rgb_alpha16

  defp read_pallete(content) do
    Enum.reverse read_pallete(content, [])
  end

  defp read_pallete(<<red::size(8), green::size(8), blue::size(8), more_pallete::binary>>, acc) do
    read_pallete(more_pallete, [{red, green, blue}| acc])
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
        %Image{image | comment: value}
      _ ->
        %Image{image | attributes: set_attribute(image, key, value)}
    end
  end

end
