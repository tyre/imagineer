defmodule Imagineer.Image.PNG.Filter.Basic.Up do
  @moduledoc """
  The Up filter transmits the difference between each byte and the value of the
  corresponding byte of the same pixel in the row above it.
  """

  @doc """
  Takes in the uncompressed binary for an up-filtered row of pixels and the
  unfiltered binary of the preceding row. It returns the a binary of the row
  as unfiltered pixel data.

  For more information, see the PNG Filter [documentation for the Up filter type
  ](http://www.w3.org/TR/PNG-Filters.html#Filter-type-2-Up).

  ## Example

      iex> filtered_row = <<127, 138, 255, 20, 21, 107>>
      iex> prior_unfiltered_row = <<1, 77, 16, 235, 55, 170>>
      iex> Imagineer.Image.PNG.Filter.Basic.Up.unfilter(filtered_row, prior_unfiltered_row)
      <<128, 215, 15, 255, 76, 21>>

  When the row being unfiltered is the first row, we pass in a binary of equal
  length that is all null bytes (`<<0>>`.)

      iex> filtered = <<1, 77, 16, 234, 234, 154>>
      iex> prior_unfiltered_row = <<0, 0, 0, 0, 0, 0>>
      iex> Imagineer.Image.PNG.Filter.Basic.Up.unfilter(filtered, prior_unfiltered_row)
      <<1, 77, 16, 234, 234, 154>>
  """
  def unfilter(row, prior_row) do
    unfilter(row, prior_row, [])
    |> Enum.join
  end

  # In the base case, we'll have a reversed list of a bunch of unfiltered bytes
  defp unfilter(<<>>, <<>>, unfiltered_bytes) do
    Enum.reverse(unfiltered_bytes)
  end

  defp unfilter(
    <<row_byte::integer-size(8), row_rest::binary>>,
    <<prior_byte::integer-size(8), prior_row_rest::binary>>,
    unfiltered_pixels)
  do
      unfiltered_byte = <<row_byte + prior_byte>>
      unfilter(row_rest, prior_row_rest, [ unfiltered_byte | unfiltered_pixels])
  end
end
