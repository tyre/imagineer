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

  @png_signature <<137::size(8), ?P, ?N, ?G, ?\r, ?\n, 26::size(8), ?\n>>

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

  def process(<<@png_signature, rest::binary>>) do
    process(rest, %PNG{})
  end

  def process(<<
      content_length::size(32),
      header::binary-size(4),
      content::binary-size(content_length),
      crc::size(32),
      rest::binary
    >>, %PNG{}=image)
  do
    case PNG.Chunk.decode(header, content, crc, image) do
      {:end, final_image} -> final_image
      in_process_image -> process(rest, in_process_image)
    end
  end

  def to_binary(%PNG{}=png) do
    to_binary(<<@png_signature>>, png)
  end

  def to_binary(bin, png) do
    processed_png = PNG.DataContent.encode(png)
    PNG.Chunk.encode({bin, processed_png}, @ihdr_header)
    |> PNG.Chunk.encode(@gama_header)
    |> PNG.Chunk.encode(@plte_header)
    |> PNG.Chunk.encode(@bkgd_header)
    |> PNG.Chunk.encode(@trns_header)
    |> PNG.Chunk.encode(@idat_header)
    |> PNG.Chunk.encode(@iend_header)
    |> Tuple.to_list
    |> List.first
  end
end
