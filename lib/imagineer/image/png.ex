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
  @iccp_header <<105, 67, 67, 80>>
  @phys_header <<112, 72, 89, 115>>

  def process(%Image{format: :png, raw: <<@png_signiture, rest::binary>>}=image) do
    process(image, rest)
  end

  # Processes the "IHDR" chunk
  def process(%Image{} = image, <<content_length::size(32), @ihdr_header, content::binary-size(content_length), _crc::size(32), rest::binary>>) do
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
    process(image, rest)
  end

  # Process "PLTE" chunk
  def process(%Image{} = image, <<content_length::integer-size(32), @plte_header, content::binary-size(content_length), _crc::size(32), rest::binary >>) do
    image = %Image{ image | attributes: set_attribute(image, :palette, read_pallete(content))}
    process(image, rest)
  end

  # Process "pHYs" chunk
  def process(%Image{} = image, <<_content_length::integer-size(32), @phys_header,
    <<x_pixels_per_unit::integer-size(32), y_pixels_per_unit::integer-size(32), _unit::binary-size(1)>>,
    _crc::size(32), rest::binary >>) do
    pixel_dimensions = {
      x_pixels_per_unit,
      y_pixels_per_unit,
      :meter}
    image = %Image{ image | attributes: set_attribute(image, :pixel_dimensions, pixel_dimensions)}
    process(image, rest)
  end

  # There can be multiple IDAT chunks to allow the encoding system to control
  # memory consumption. Append the content
  def process(%Image{} = image, <<content_length::integer-size(32), @idat_header, content::binary-size(content_length), _crc::size(32), rest::binary >>) do
    process(%Image{ image | content: image.content <> content}, rest)
  end

  # The end of the PNG
  def process(%Image{} = image, <<_length::size(32), @iend_header, _rest::binary>>) do
    image
  end

  # process the auxillary "bKGD" chunk
  def process(%Image{} = image, <<content_length::size(32), @bkgd_header, content::binary-size(content_length), _crc::size(32), rest::binary>>) do
    color_type = image.attributes.color_type
    background_color = case content do
      <<index::size(8)>> when color_type == 3 ->
        index
      <<gray::size(16)>> when color_type == 0 or color_type == 4 ->
        gray
      <<red::size(16), green::size(16), blue::size(16)>> when color_type == 2 or color_type == 6 ->
        {red, green, blue}
      _ ->
        :undefined
    end

    image = %Image{ image | attributes: set_attribute(image, :background_color, background_color)}
    process(image, rest)
  end

  # For headers that we don't understand, skip them
  def process(%Image{} = image, <<content_length::size(32), _h::size(8), _e::size(8), _a::size(8), _d::size(8),
      _content::binary-size(content_length), _crc::size(32), rest::binary>>) do
    process(image, rest)
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

end
