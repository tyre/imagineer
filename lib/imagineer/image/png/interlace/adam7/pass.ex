defmodule Imagineer.Image.PNG.Interlace.Adam7.Pass do
  use Bitwise
  @moduledoc """
  Methods for decoding and encoding Adam7 interlacing.
  Credit to the Ruby [ChunkyPNG](https://github.com/wvanbergen/chunky_png/blob/master/lib/chunky_png/canvas/adam7_interlacing.rb)
  project for bitwisdom.

  """
  @pass_1_x_shift   3
  @pass_1_x_offset  0
  @pass_1_y_shift   3
  @pass_1_y_offset  0

  @pass_2_x_shift   3
  @pass_2_x_offset  4
  @pass_2_y_shift   3
  @pass_2_y_offset  0

  @pass_3_x_shift   2
  @pass_3_x_offset  0
  @pass_3_y_shift   3
  @pass_3_y_offset  4

  @pass_4_x_shift   2
  @pass_4_x_offset  2
  @pass_4_y_shift   2
  @pass_4_y_offset  0

  @pass_5_x_shift   1
  @pass_5_x_offset  0
  @pass_5_y_shift   2
  @pass_5_y_offset  2

  @pass_6_x_shift   1
  @pass_6_x_offset  1
  @pass_6_y_shift   1
  @pass_6_y_offset  0

  @pass_7_x_shift   0
  @pass_7_x_offset  0
  @pass_7_y_shift   1
  @pass_7_y_offset  1

  @doc """
  Returns a list of the dimension of all the pass images.
  """
  def sizes(original_width, original_height) do
    Enum.map(1..7, fn (pass) ->
      size(pass, original_width, original_height)
    end)
  end

  # Returns the width and height of a given pass' pixels.
  def size(pass, original_width, original_height) do
    {x_shift, x_offset, y_shift, y_offset} = multiplier_offset(pass)
    {
      (original_width  - x_offset + (1 <<< x_shift) - 1) >>> x_shift,
      (original_height - y_offset + (1 <<< y_shift) - 1) >>> y_shift
    }
  end

  def merge(pass, {original_width, original_height}, pass_pixels, image_pixels) do
    {sub_width, sub_height} = size(pass, original_width, original_height)
    {x_shift, x_offset, y_shift, y_offset} = multiplier_offset(pass)
    if sub_height > 0 and sub_width > 0 do
      Enum.reduce(0..(sub_height-1), image_pixels, fn(sub_y, filled_image_pixels) ->
        image_y = (sub_y <<< y_shift) ||| y_offset
        sub_image_row = Enum.at(pass_pixels, sub_y)
        current_row = :array.get(image_y, filled_image_pixels)
        new_row = Enum.reduce(0..(sub_width-1), current_row, fn(sub_x, updated_row) ->
          image_x = (sub_x <<< x_shift) ||| x_offset
          :array.set(image_x, Enum.at(sub_image_row, sub_x), updated_row)
        end)
        :array.set(image_y, new_row, filled_image_pixels)
      end)
    else
      image_pixels
    end
  end

  # Extracts the sub image for the given pass
  #
  def extract_pass(pass, original_height, original_width, image_pixels) do
    {x_shift, x_offset, y_shift, y_offset} = multiplier_offset(pass)
    # If the offset is greater than the height/width, the pass is empty
    if original_height > y_offset && original_width > x_offset do
      Enum.slice(image_pixels, y_offset..-1)
      |> Enum.take_every(1 <<< y_shift)
      |> Enum.map(fn (row) ->
        Enum.slice(row, x_offset..-1)
        |> Enum.take_every(1 <<< x_shift)
      end)
    else
      []
    end
  end

  # Returns a tuple with the x-shift, x-offset, y-shift and y-offset for the
  # requested pass.
  defp multiplier_offset(1) do
    { @pass_1_x_shift, @pass_1_x_offset, @pass_1_y_shift, @pass_1_y_offset }
  end

  defp multiplier_offset(2) do
    { @pass_2_x_shift, @pass_2_x_offset, @pass_2_y_shift, @pass_2_y_offset }
  end

  defp multiplier_offset(3) do
    { @pass_3_x_shift, @pass_3_x_offset, @pass_3_y_shift, @pass_3_y_offset }
  end

  defp multiplier_offset(4) do
    { @pass_4_x_shift, @pass_4_x_offset, @pass_4_y_shift, @pass_4_y_offset }
  end

  defp multiplier_offset(5) do
    { @pass_5_x_shift, @pass_5_x_offset, @pass_5_y_shift, @pass_5_y_offset }
  end

  defp multiplier_offset(6) do
    { @pass_6_x_shift, @pass_6_x_offset, @pass_6_y_shift, @pass_6_y_offset }
  end

  defp multiplier_offset(7) do
    { @pass_7_x_shift, @pass_7_x_offset, @pass_7_y_shift, @pass_7_y_offset }
  end
end
