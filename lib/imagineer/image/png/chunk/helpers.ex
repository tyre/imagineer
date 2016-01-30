defmodule Imagineer.Image.PNG.Chunk.Helpers do
  alias Imagineer.Image.PNG
  defmacro decode_chunk(header, options) do
    quote do
      defp decode_chunk(unquote(header), content, %PNG{}=image) do
        unquote(options[:with]).decode(content, image)
      end
    end
  end
end
