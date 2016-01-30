defmodule Imagineer.Image.PNG.Filter.Basic do
  alias Imagineer.Image.PNG
  alias PNG.Filter.Basic
  import PNG.Helpers, only: [ bytes_per_pixel: 2, bytes_per_row: 3, null_binary: 1 ]
  @none    0
  @sub     1
  @up      2
  @average 3
  @paeth   4

  @doc """
  Takes an image's scanlines and returns the rows unfiltered

  Types are defined [here](http://www.w3.org/TR/PNG-Filters.html).
  """
  def unfilter(scanlines, %PNG{
    color_format: color_format, bit_depth: bit_depth, width: width
  }) do
    # For unfiltering, the row prior to the first is assumed to be all 0s
    ghost_row = null_binary(bytes_per_row(color_format, bit_depth, width))
    unfilter(scanlines, ghost_row, bytes_per_pixel(color_format, bit_depth), [])
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

  @doc """
  Filters scanlines. Right now does a naïve pass (AKA no filtering.)
  """
  def filter(unfiltered_rows, _image) do
    filter_rows(unfiltered_rows)
  end

  defp filter_rows(unfiltered_rows) do
    filter_rows(unfiltered_rows, [])
  end

  defp filter_rows([], filtered_rows) do
    Enum.reverse filtered_rows
  end

  defp filter_rows([unfiltered_row | rest_unfiltered], filtered_rows) do
    filter_rows(rest_unfiltered, [filter_row(unfiltered_row) | filtered_rows])
  end

  # Proprietary optimization technique
  defp filter_row(unfiltered_row) do
    <<@none::integer-size(8), unfiltered_row::bits>>
  end
end
