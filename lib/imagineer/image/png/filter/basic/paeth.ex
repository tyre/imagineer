defmodule Imagineer.Image.PNG.Filter.Basic.Paeth do
  import Imagineer.Image.PNG.Helpers, only: [ null_binary: 1 ]

  @doc """
  Takes in the uncompressed binary representation of a row, the unfiltered row
  row above it, and the number of bytes per pixel. Decodes according to the
  Paeth filter.

  For more information, see the PNG documentation for the [Paeth filter type]
  (http://www.w3.org/TR/PNG-Filters.html#Filter-type-4-Paeth)

  ## Examples

      iex> unfiltered_prior_row = <<18, 39, 117, 39, 201, 7>>
      iex> filtered_row = <<86, 5, 226, 185, 146, 181>>
      iex> Imagineer.Image.PNG.Filter.Basic.Paeth.unfilter(filtered_row, unfiltered_prior_row, 3)
      <<104, 44, 87, 33, 91, 188>>

      iex> unfiltered_prior_row = <<18, 39, 117, 39, 201, 7>>
      iex> filtered_row = <<86, 5, 226, 245, 146, 181>>
      iex> Imagineer.Image.PNG.Filter.Basic.Paeth.unfilter(filtered_row, unfiltered_prior_row, 2)
      <<104, 44, 87, 33, 91, 188>>
  """
  def unfilter(row, prior_row, bytes_per_pixel) do
    # For the first pixel, which has no upper left or left, we fill them in as
    # null-filled binaries (`<<0>>`.)
    upper_left_ghost_pixel = left_ghost_pixel = null_binary(bytes_per_pixel)
    unfilter(row, prior_row, left_ghost_pixel, upper_left_ghost_pixel, bytes_per_pixel, [])
    |> Enum.join()
  end

  # In the base case, we'll have a reversed list of binaries, each containing
  # the unfiltered bytes of their respective pixel
  defp unfilter(<<>>, <<>>, _left_pixel, _upper_left_pixel, _bytes_per_pixel, unfiltered_pixels) do
    Enum.reverse unfiltered_pixels
  end

  defp unfilter(row, prior_row, left_pixel, upper_left_pixel, bytes_per_pixel, unfiltered_pixels) do
    <<row_pixel::bytes-size(bytes_per_pixel), row_rest::binary>> = row
    <<above_pixel::bytes-size(bytes_per_pixel), prior_row_rest::binary>> = prior_row
    unfiltered_pixel = unfilter_pixel(row_pixel, left_pixel, above_pixel, upper_left_pixel)
    unfilter(row_rest, prior_row_rest, unfiltered_pixel, above_pixel, bytes_per_pixel, [unfiltered_pixel | unfiltered_pixels])
  end

  defp unfilter_pixel(row_pixel, left_pixel, above_pixel, upper_left_pixel) do
    unfilter_pixel(row_pixel, left_pixel, above_pixel, upper_left_pixel, [])
    |> Enum.join()
  end

  # In the base case, we'll have run through each of the bytes and have a
  # reversed list of unfiltered bytes
  defp unfilter_pixel(<<>>, <<>>, <<>>, <<>>, unfiltered_pixel_bytes) do
    Enum.reverse unfiltered_pixel_bytes
  end

# Paeth(x) + PaethPredictor(Raw(x-bpp), Prior(x), Prior(x-bpp))

  defp unfilter_pixel(
    <<filtered_pixel_byte::integer-size(8), filtered_pixel_rest::binary>>,
    <<left_pixel_byte::integer-size(8), left_pixel_rest::binary>>,
    <<above_pixel_byte::integer-size(8), above_pixel_rest::binary>>,
    <<upper_left_pixel_byte::integer-size(8), upper_left_pixel_rest::binary>>,
    unfiltered_pixel_bytes)
  do
    nearest_byte = predictor(left_pixel_byte, above_pixel_byte, upper_left_pixel_byte)
    unfiltered_byte = <<filtered_pixel_byte + nearest_byte>>
    unfilter_pixel(
      filtered_pixel_rest,
      left_pixel_rest,
      above_pixel_rest,
      upper_left_pixel_rest,
      [unfiltered_byte | unfiltered_pixel_bytes]
    )
  end

  @doc """
  The Paeth prediction is calculated as `left + above - upper_left`.
  This function returns the value nearest to the Paeth prediction, breaking ties
  in the order of left, above, upper_left.

  For more information, see the PNG documentation for the [Paeth filter type]
  (http://www.w3.org/TR/PNG-Filters.html#Filter-type-4-Paeth)

  ## Example

      iex> Imagineer.Image.PNG.Filter.Basic.Paeth.predictor(37, 84, 1)
      84

      iex> Imagineer.Image.PNG.Filter.Basic.Paeth.predictor(118, 128, 125)
      118

      iex> Imagineer.Image.PNG.Filter.Basic.Paeth.predictor(37, 84, 61)
      61
  """
  def predictor(left, above, upper_left) do
    prediction = left + above - upper_left
    nearest_to_prediction(prediction, left, above, upper_left)
  end

  defp nearest_to_prediction(prediction, left, above, upper_left)
    when abs(prediction - left) <= abs(prediction - above)
    and abs(prediction - left) <= abs(prediction - upper_left)
  do
    left
  end

  defp nearest_to_prediction(prediction, _left, above, upper_left)
    when abs(prediction - above) <= abs(prediction - upper_left)
  do
    above
  end

  defp nearest_to_prediction(_prediction, _left, _above, upper_left) do
    upper_left
  end
end

