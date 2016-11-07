defmodule Imagineer.Image.JPEG.Markers.Helpers do
  alias Imagineer.Image.JPEG
  defmacro decode_marker(marker_identifier, options) do
    require Logger
    quote do
      defp decode_marker(unquote(marker_identifier), content, %JPEG{}=image, rest) do
        Logger.debug("decoding #{unquote(marker_identifier)}")
        if unquote(options[:include_rest]) do
          unquote(options[:with]).decode(content, image, rest)
        else
          unquote(options[:with]).decode(content, image)
        end
      end
    end
  end
end
