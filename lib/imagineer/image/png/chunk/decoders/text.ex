defmodule Imagineer.Image.PNG.Chunk.Decoders.Text do
  alias Imagineer.Image.PNG

  def decode(content, %PNG{}=image) do
    decode_text_chunk(image, content)
  end

  defp decode_text_chunk(image, content) do
    case decode_text_pair(content, <<>>) do
      {key, value} ->
        set_text_attribute(image, key, value)
      false ->
        image
    end
  end

  defp decode_text_pair(<<0, value::binary>>, key) do
    {String.to_atom(key), strip_null_bytes(value)}
  end

  defp decode_text_pair(<<key_byte::binary-size(1), rest::binary>>, key) do
    decode_text_pair(rest, key <> key_byte)
  end

  defp decode_text_pair(<<>>, _key), do: false

  # Strip all leading null bytes (<<0>>) from the text
  defp strip_null_bytes(<<0, rest::binary>>), do: strip_null_bytes(rest)
  defp strip_null_bytes(content), do: content

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

  defp set_attribute(image, key, value) do
    Map.put image.attributes, key, value
  end

end
