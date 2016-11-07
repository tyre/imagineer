defmodule Imagineer.Image.JPEG.Markers.Decoders.QuantizationTable do
  @num_table_entries 64

  def decode(table_content, image) do
    decode_tables(table_content, image)
  end

  defp decode_tables(<<>>, image, tables) do
    %{image | quantization_tables: Enum.reverse(tables) }
  end

  defp decode_tables(<<
      table_depth_identifier::integer-size(4),
      table_identifier::integer-size(4),
      table_content::binary
    >>,
    image,
    tables\\[])
  do
    # If the first four bits are 0, each table number is one byte.
    # If the first four bits are 1, each table number is two bytes.
    table_depth = (table_depth_identifier + 1) * 8
    # There are 64 entries
    table_size = @num_table_entries * table_depth
    <<
      next_table_content::size(table_size),
      rest_table_content::binary
    >> = table_content
    next_table = decode_table(table_depth, table_content)
    decode_tables(rest_table_content, image, [{table_identifier, next_table} | tables])
  end

  # In the base case, we have run out of entries and need to return them
  defp decode_table(table_depth, <<>>, entries) do
    Enum.reverse(entries)
  end

  defp decode_table(table_depth, table_content, entries\\[]) do
    <<next_entry::integer-size(table_depth), rest_content::binary>> = table_content
    decode_table(table_depth, rest_content, [next_entry | entries])
  end
end
