defmodule Imagineer.Image.PNG.Filter.Basic.Average do
  import Imagineer.Image.PNG.Helpers, only: [ null_binary: 1 ]
  @moduledoc """
  The Average filter computes value for a pixel based on the average between the
  pixel to its left and the pixel directly above it.
  """

  @doc """
  Takes in the uncompressed binary for an average-filtered row of pixels, the
  unfiltered binary of the preceding row, and the number of bytes per pixel. It
  returns the a binary of the row as unfiltered pixel data.

  For more information, see the PNG Filter [documentation for the Average filter type
  ](http://www.w3.org/TR/PNG-Filters.html#Filter-type-3-Average).

  ## Example

      iex> filtered = <<13, 191, 74, 228, 149, 158>>
      iex> prior_unfiltered_row = <<8, 215, 35, 113, 28, 112>>
      iex> Imagineer.Image.PNG.Filter.Basic.Average.unfilter(filtered, prior_unfiltered_row, 3)
      <<17, 42, 91, 37, 184, 3>>

      iex> filtered = <<13, 191, 74, 228, 149, 158>>
      iex> prior_unfiltered_row = <<8, 215, 35, 113, 28, 112>>
      iex> Imagineer.Image.PNG.Filter.Basic.Average.unfilter(filtered, prior_unfiltered_row, 2)
      <<17, 42, 100, 49, 213, 238>>
  """
  def unfilter(row, prior_row, bytes_per_pixel) do
    # For the first row, the preceding pixel bytes are all zeros
    ghost_pixel = null_binary(bytes_per_pixel)
    unfilter(row, prior_row, ghost_pixel, bytes_per_pixel, [])
    |> Enum.join
  end

  # In the base case, `unfiltered_pixels` will be a reversed list of lists, each
  # sublist of which contains the unfiltered bytes for that pixel
  defp unfilter(<<>>, <<>>, _prior_pixel, _bytes_per_pixel, unfiltered_pixels) do
    Enum.reverse unfiltered_pixels
  end

  defp unfilter(row, prior_row, prior_pixel, bytes_per_pixel, unfiltered_pixels) do
    <<row_pixel::bytes-size(bytes_per_pixel), row_rest::binary>> = row
    <<prior_row_pixel::bytes-size(bytes_per_pixel), prior_row_rest::binary>> = prior_row
    unfiltered_pixel = unfilter_pixel(row_pixel, prior_row_pixel, prior_pixel)
    unfilter(row_rest, prior_row_rest, unfiltered_pixel, bytes_per_pixel, [unfiltered_pixel | unfiltered_pixels])
  end

  defp unfilter_pixel(row_pixel, prior_row_pixel, prior_pixel) do
    unfilter_pixel(row_pixel, prior_row_pixel, prior_pixel, [])
    |> Enum.join
  end

  # In the base case, `unfiltered_bytes` is a reveresed list of the unfiltered
  # bytes for this one pixel
  defp unfilter_pixel(<<>>, <<>>, <<>>, unfiltered_bytes) do
    Enum.reverse unfiltered_bytes
  end

  # To unfilter a given pixel's byte, we take the average of the corresponding
  # byte of the pixel above it (`prior_row_pixel`) and the the corresponding
  # byte of the pixel immediately to its left (`prior_pixel`.) We then take the
  # floor of the average of these two and add it to our filtered byte (
  # `row_pixel_byte`. That number modulo 256 (so it fits into a byte) is our
  # answer.
  #
  # Who comes up with this shit?
  defp unfilter_pixel(
    <<row_pixel_byte::integer-size(8), row_pixel_rest::binary>>,
    <<prior_row_pixel_byte::integer-size(8), prior_row_pixel_rest::binary>>,
    <<prior_pixel_byte::integer-size(8), prior_pixel_rest::binary>>,
    unfiltered_bytes)
  do
    # We use `Kernel.trunc` to turn get the floor of the average as an integer
    unfiltered_byte = row_pixel_byte + trunc((prior_pixel_byte + prior_row_pixel_byte)/2)
    unfiltered_bytes = [<<unfiltered_byte>> | unfiltered_bytes]
    unfilter_pixel(row_pixel_rest, prior_row_pixel_rest, prior_pixel_rest, unfiltered_bytes)
  end

end
