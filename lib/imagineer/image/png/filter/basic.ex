defmodule Imagineer.Image.PNG.Filter.Basic do
  alias Imagineer.Image.PNG
  alias PNG.Filter.Basic
  import PNG.Helpers, only: [ bytes_per_pixel: 1, bytes_per_row: 2, null_binary: 1 ]
  @none    0
  @sub     1
  @up      2
  @average 3
  @paeth   4

  @doc """
  Takes an image and its decompressed content. Returns the rows unfiltered with
  their respective index.

  Types are defined [here](http://www.w3.org/TR/PNG-Filters.html).
  """
  def unfilter(scanlines, color_format, width)
  when is_list(scanlines) and is_atom(color_format) and is_integer(width) do
    # For unfiltering, the row prior to the first is assumed to be all 0s
    ghost_row = null_binary(bytes_per_row(color_format, width))
    unfilter(scanlines, ghost_row, bytes_per_pixel(color_format), [])
  end

  defp unfilter([], _prior_row, _bytes_per_pixel, unfiltered) do
    Enum.reverse unfiltered
  end

  defp unfilter([filtered_row | filtered_rows], prior_row, bytes_per_pixel, unfiltered) do
    unfiltered_row = pad_row(filtered_row)
    |> unfilter_scanline(bytes_per_pixel, prior_row)
    unfilter(filtered_rows, unfiltered_row, bytes_per_pixel, [unfiltered_row | unfiltered])
  end

  defp unfilter_scanline(<<@none::integer-size(8), row_content::binary>>, _bytes_per_pixel, _prior) do
    row_content
  end

  defp unfilter_scanline(<<@sub::integer-size(8), row_content::binary>>, bytes_per_pixel, _prior) do
    Basic.Sub.unfilter(row_content, bytes_per_pixel)
  end

  defp unfilter_scanline(<<@up::integer-size(8), row_content::binary>>, _bytes_per_pixel, prior_row) do
    Basic.Up.unfilter(row_content, prior_row)
  end

  defp unfilter_scanline(<<@average::integer-size(8), row_content::binary>>, bytes_per_pixel, prior_row) do
    Basic.Average.unfilter(row_content, prior_row, bytes_per_pixel)
  end

  defp unfilter_scanline(<<@paeth::integer-size(8), row_content::binary>>, bytes_per_pixel, prior_row) do
    Basic.Paeth.unfilter(row_content, prior_row, bytes_per_pixel)
  end

  defp pad_row(row) when rem(bit_size(row), 8) != 0 do
    pad_row <<row::bits, 0::1>>
  end

  defp pad_row(row) do
    row
  end
end
