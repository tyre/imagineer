defmodule Imagineer.Image.PNG.Helpers do
  @doc """
  Given a PNG's color type, returns its color format
  """
  def color_format(0), do: :grayscale
  def color_format(2), do: :rgb
  def color_format(3), do: :palette
  def color_format(4), do: :grayscale_alpha
  def color_format(6), do: :rgb_alpha

  @doc """
  Given a color format, bit depth, and the width of an image, tells us how many
  bytes are are present per scanline (a row of pixels).
  """
  def bytes_per_row(:grayscale, 1, width), do: div(width + 7, 8)
  def bytes_per_row(:grayscale, 2, width), do: div(width + 3, 4)
  def bytes_per_row(:grayscale, 4, width), do: div(width + 1, 2)
  def bytes_per_row(:grayscale, 8, width), do: width
  def bytes_per_row(:grayscale, 16, width), do: width * 2
  def bytes_per_row(:rgb, 8, width), do: width * 3
  def bytes_per_row(:rgb, 16, width), do: width * 6
  def bytes_per_row(:palette, 1, width), do: div(width + 7, 8)
  def bytes_per_row(:palette, 2, width), do: div(width + 3, 4)
  def bytes_per_row(:palette, 4, width), do: div(width + 1, 2)
  def bytes_per_row(:palette, 8, width), do: width
  def bytes_per_row(:grayscale_alpha, 8, width), do: width * 2
  def bytes_per_row(:grayscale_alpha, 16, width), do: width * 4
  def bytes_per_row(:rgb_alpha, 8, width), do: width * 4
  def bytes_per_row(:rgb_alpha, 16, width), do: width * 8

  @doc """
  Given a color format and bit depth, tells us how many bytes are needed to
  store a pixel
  """
  def bytes_per_pixel(:grayscale, 1), do: 1
  def bytes_per_pixel(:grayscale, 2), do: 1
  def bytes_per_pixel(:grayscale, 4), do: 1
  def bytes_per_pixel(:grayscale, 8), do: 1
  def bytes_per_pixel(:grayscale, 16), do: 2
  def bytes_per_pixel(:rgb, 8), do: 3
  def bytes_per_pixel(:rgb, 16), do: 6
  def bytes_per_pixel(:palette, 1), do: 1
  def bytes_per_pixel(:palette, 2), do: 1
  def bytes_per_pixel(:palette, 4), do: 1
  def bytes_per_pixel(:palette, 8), do: 1
  def bytes_per_pixel(:grayscale_alpha, 8), do: 2
  def bytes_per_pixel(:grayscale_alpha, 16), do: 4
  def bytes_per_pixel(:rgb_alpha, 8), do: 4
  def bytes_per_pixel(:rgb_alpha, 16), do: 8

  @doc """
  Returns the number of channels for a given `color_format`. For example,
  `:rgb` and `:rbg16` have 3 channels: one for Red, Green, and Blue.
  `:rgb_alpha` and `:rgb_alpha` each have 4 channels: one for Red, Green,
  Blue, and the alpha (transparency) channel.
  """
  def channels_per_pixel(:palette), do: 1
  def channels_per_pixel(:grayscale), do: 1
  def channels_per_pixel(:grayscale_alpha), do: 2
  def channels_per_pixel(:rgb), do: 3
  def channels_per_pixel(:rgb_alpha), do: 4

  @doc """
  Returns a binary consisting of `length` null (`<<0>>`) bytes
  """
  def null_binary(length) when length >= 0 do
    null_binary(<<>>, length)
  end

  defp null_binary(null_bytes, 0) do
    null_bytes
  end

  defp null_binary(null_bytes, length) do
    null_binary(null_bytes <> <<0>>, length - 1)
  end
end
