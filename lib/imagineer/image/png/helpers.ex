defmodule Imagineer.Image.PNG.Helpers do

  @doc """
  Given a PNG's color type and bit depth, returns its color format
  """
  def color_format(0, 1) , do: :grayscale1
  def color_format(0, 2) , do: :grayscale2
  def color_format(0, 4) , do: :grayscale4
  def color_format(0, 8) , do: :grayscale8
  def color_format(0, 16), do: :grayscale16
  def color_format(2, 8) , do: :rgb8
  def color_format(2, 16), do: :rgb16
  def color_format(3, 1) , do: :palette1
  def color_format(3, 2) , do: :palette2
  def color_format(3, 4) , do: :palette4
  def color_format(3, 8) , do: :palette8
  def color_format(4, 8) , do: :grayscale_alpha8
  def color_format(4, 16), do: :grayscale_alpha16
  def color_format(6, 8) , do: :rgb_alpha8
  def color_format(6, 16), do: :rgb_alpha16

  @doc """
  Given a color format and the width of an image, tells us how many bytes are
  are present per scanline (a row of pixels).
  """
  def bytes_per_row(:grayscale1, width),          do: div(width + 7, 8)
  def bytes_per_row(:grayscale2, width),          do: div(width + 3, 4)
  def bytes_per_row(:grayscale4, width),          do: div(width + 1, 2)
  def bytes_per_row(:grayscale8, width),          do: width
  def bytes_per_row(:grayscale16, width),         do: width * 2
  def bytes_per_row(:rgb8, width),                do: width * 3
  def bytes_per_row(:rgb16, width),               do: width * 6
  def bytes_per_row(:palette1, width),            do: div(width + 7, 8)
  def bytes_per_row(:palette2, width),            do: div(width + 3, 4)
  def bytes_per_row(:palette4, width),            do: div(width + 1, 2)
  def bytes_per_row(:palette8, width),            do: width
  def bytes_per_row(:grayscale_alpha8, width),    do: width * 2
  def bytes_per_row(:grayscale_alpha16, width),   do: width * 4
  def bytes_per_row(:rgb_alpha8, width),          do: width * 4
  def bytes_per_row(:rgb_alpha16, width),         do: width * 8

  @doc """
  Gives how many bits comprise a channel, based on the color format
  """
  def bits_per_channel(:grayscale1),          do: 1
  def bits_per_channel(:grayscale2),          do: 2
  def bits_per_channel(:grayscale4),          do: 4
  def bits_per_channel(:grayscale8),          do: 8
  def bits_per_channel(:grayscale16),         do: 16
  def bits_per_channel(:rgb8),                do: 8
  def bits_per_channel(:rgb16),               do: 16
  def bits_per_channel(:palette1),            do: 1
  def bits_per_channel(:palette2),            do: 2
  def bits_per_channel(:palette4),            do: 4
  def bits_per_channel(:palette8),            do: 8
  def bits_per_channel(:grayscale_alpha8),    do: 8
  def bits_per_channel(:grayscale_alpha16),   do: 16
  def bits_per_channel(:rgb_alpha8),          do: 8
  def bits_per_channel(:rgb_alpha16),         do: 16


  @doc """
  Given a color format, tells us how many bytes are needed to store a pixel
  """
  def bytes_per_pixel(:grayscale1),         do: 1
  def bytes_per_pixel(:grayscale2),         do: 1
  def bytes_per_pixel(:grayscale4),         do: 1
  def bytes_per_pixel(:grayscale8),         do: 1
  def bytes_per_pixel(:grayscale16),        do: 2
  def bytes_per_pixel(:rgb8),               do: 3
  def bytes_per_pixel(:rgb16),              do: 6
  def bytes_per_pixel(:palette1),           do: 1
  def bytes_per_pixel(:palette2),           do: 1
  def bytes_per_pixel(:palette4),           do: 1
  def bytes_per_pixel(:palette8),           do: 1
  def bytes_per_pixel(:grayscale_alpha8),   do: 2
  def bytes_per_pixel(:grayscale_alpha16),  do: 4
  def bytes_per_pixel(:rgb_alpha8),         do: 4
  def bytes_per_pixel(:rgb_alpha16),        do: 8

  @doc """
  Returns the number of channels for a given `color_format`. For example,
  `:rgb8` and `:rbg16` have 3 channels: one for Red, Green, and Blue.
  `:rgb_alpha8` and `:rgb_alpha16` each have 4 channels: one for Red, Green,
  Blue, and the alpha (transparency) channel.
  """
  def channels_per_pixel(:palette1),           do: 1
  def channels_per_pixel(:palette2),           do: 1
  def channels_per_pixel(:palette4),           do: 1
  def channels_per_pixel(:palette8),           do: 1
  def channels_per_pixel(:grayscale1),         do: 1
  def channels_per_pixel(:grayscale2),         do: 1
  def channels_per_pixel(:grayscale4),         do: 1
  def channels_per_pixel(:grayscale8),         do: 1
  def channels_per_pixel(:grayscale16),        do: 1
  def channels_per_pixel(:grayscale_alpha8),   do: 2
  def channels_per_pixel(:grayscale_alpha16),  do: 2
  def channels_per_pixel(:rgb8),               do: 3
  def channels_per_pixel(:rgb16),              do: 3
  def channels_per_pixel(:rgb_alpha8),         do: 4
  def channels_per_pixel(:rgb_alpha16),        do: 4


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
