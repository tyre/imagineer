defmodule Imagineer.Image.PNG do
  alias Imagineer.Image

  @png_signiture <<137::size(8), 80::size(8), 78::size(8), 71::size(8),
                   13::size(8),  10::size(8), 26::size(8), 10::size(8)>>
  @ihdr_header <<73::size(8), 72::size(8), 68::size(8), 82::size(8)>>
  @idat_header <<73::size(8), 68::size(8), 65::size(8), 84::size(8)>>
  @iend_header <<73::size(8), 69::size(8), 78::size(8), 68::size(8)>>

  def process(%Image{format: :png, raw: raw}=image) do
    process_header(image, raw)
  end

  def process_header(image, <<@png_signiture, rest::binary>>) do
    process_header(image, rest)
  end


  def process_header(%Image{} = image, <<content_length::size(32), @ihdr_header, content::binary-size(content_length), _crc::size(32), rest::binary>>) do
    <<width::integer-size(32),
      height::integer-size(32), data_precision::integer,
      color_type::integer, compression::integer, filter_method::integer,
      interface_method::integer>> = content
    header = Map.merge image.header, %{
      data_precision: data_precision,
      color_type: color_type_code(color_type),
      compression: compression,
      filter_method: filter_method,
      interface_method: interface_method
    }

    process_header(%Image{ image | header: header, width: width, height: height }, rest)
  end

  def process_header(%Image{} = image, <<_length::size(32), @iend_header, _rest::binary>>) do
    image
  end

  # There can be multiple IDAT chunks to allow the encoding system to control
  # memory consumption. Append the content
  def process_header(%Image{ header: header } = image, <<content_length::integer-size(32), @idat_header, content::binary-size(content_length), _crc::size(32), rest::binary >>) do
    header = Map.merge header, %{ content: image.content <> content }
    process_header(%Image{ image | header: header }, rest)
  end


  # For headers that we don't understand, skip them
  def process_header(%Image{} = image, <<content_length::size(32), _header::size(32),
      _content::binary-size(content_length), _crc::size(32), rest::binary>>) do
    process_header(image, rest)
  end


  defp color_type_code(color_type) when is_integer(color_type) do
    case color_type do
      0 -> :grayscale
      2 -> :rgb
      3 -> :palette
      4 -> :grayscale_alpha
      6 -> :rgb_alpha
      _ -> IO.format("Unrecognize color type #{color_type}")
    end
  end

          # 1,2,4,8,16  Each pixel is a grayscale sample.

          # 8,16        Each pixel is an R,G,B triple.

          # 1,2,4,8     Each pixel is a palette index;
          #              a PLTE chunk must appear.

          # 8,16        Each pixel is a grayscale sample,
          #              followed by an alpha sample.

          # 8,16        Each pixel is an R,G,B triple,
          #              followed by an alpha sample.


end
