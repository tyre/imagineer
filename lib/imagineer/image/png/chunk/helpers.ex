defmodule Imagineer.Image.PNG.Chunk.Helpers do
  alias Imagineer.Image.PNG
  defmacro decode_chunk(header, options) do
    quote do
      defp decode_chunk(unquote(header), content, %PNG{}=image) do
        unquote(options[:with]).decode(content, image)
      end
    end
  end

  defmacro encode_chunk(header, options) do
    quote do
      defp encode_chunk(unquote(header), bin, %PNG{}=image) do
        chunk_content = unquote(options[:with]).encode(image)
        if chunk_content do
          {write_header(unquote(header), chunk_content, bin), image}
        else
          {bin, image}
        end
      end
    end
  end

  def write_header(header, chunk_content, bin) do
    content_length = byte_size(chunk_content)
    cyclic_redundency_check = :erlang.crc32(header <> chunk_content)
    chunk = <<
      content_length::integer-unit(1)-size(32),
      header::binary-size(4),
      chunk_content::binary,
      cyclic_redundency_check::size(32)
    >>
    bin <> chunk
  end
end
