defmodule Imagineer.Image.PNG.Filter.Basic.Sub do
  import Imagineer.Image.PNG.Helpers, only: [ null_binary: 1 ]
  @moduledoc """
  The Sub filter transmits the difference between each byte and the value of the
  corresponding byte of the prior pixel.
  """

  @doc """
  Takes in the uncompressed binary for a sub-filtered row of pixels plus the
  number of bytes per pixel and returns the a binary of the row as
  unfiltered pixel data.

  For more information, see the PNG Filter [documentation for the Sub filter type
  ](http://www.w3.org/TR/PNG-Filters.html#Filter-type-1-Sub).

  ## Example

      iex> filtered = <<127, 138, 255, 20, 21, 107>>
      iex> Imagineer.Image.PNG.Filter.Basic.Sub.unfilter(filtered, 3)
      <<127, 138, 255, 147, 159, 106>>

      iex> filtered = <<1, 77, 16, 234, 234, 154>>
      iex> Imagineer.Image.PNG.Filter.Basic.Sub.unfilter(filtered, 3)
      <<1, 77, 16, 235, 55, 170>>

      iex> filtered = <<1, 77, 16, 234, 234, 154>>
      iex> Imagineer.Image.PNG.Filter.Basic.Sub.unfilter(filtered, 2)
      <<1, 77, 17, 55, 251, 209>>
  """
  def unfilter(row, bytes_per_pixel) do
    # the pixel data before the first pixel is assumed to be all bagels
    ghost_prior_pixel = null_binary(bytes_per_pixel)
    unfilter(row, ghost_prior_pixel, bytes_per_pixel, [])
    |> Enum.join
  end

  # In the base case, we'll have a reversed list of lists, each of which
  # contains a the unfiltered bytes for a pixel. Flatten them
  defp unfilter(<<>>, _prior_pixel, _bytes_per_pixel, unfiltered_pixels) do
    List.flatten Enum.reverse unfiltered_pixels
  end

  defp unfilter(row, prior_pixel, bytes_per_pixel, unfiltered_pixels) do
      <<pixel_bytes::bytes-size(bytes_per_pixel), rest::binary>> = row
      unfiltered_pixel_bytes = unfilter_pixel_bytes(prior_pixel, pixel_bytes, [])
      unfiltered_pixel = Enum.join(unfiltered_pixel_bytes)
      unfilter(rest, unfiltered_pixel, bytes_per_pixel, [ unfiltered_pixel_bytes | unfiltered_pixels])
  end

  # In the base case, we'll have a reversed list of a bunch of unfiltered bytes
  defp unfilter_pixel_bytes(<<>>, <<>>, unfiltered_bytes) do
    Enum.reverse(unfiltered_bytes)
  end

  # Adds the corresponding byte values of the current pixel and the previous one
  defp unfilter_pixel_bytes(
    <<prior_byte::integer-size(8), rest_prior::binary>>,
    <<pixel_byte::integer-size(8), rest_pixel::binary>>,
    unfiltered_bytes)
  do
    unfiltered_byte = <<prior_byte + pixel_byte>>
    unfilter_pixel_bytes(rest_prior, rest_pixel, [unfiltered_byte | unfiltered_bytes])
  end
end
