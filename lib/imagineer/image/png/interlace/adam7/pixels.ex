defmodule Imagineer.Image.PNG.Interlace.Adam7.Pixels do
  # alias Imagineer.Image.PNG

  # def extract(%PNG{width: width, height: height, scanlines: passes}=image) do
  #   Enum.reduce(1..7, [], fn (pass_index, split_passes) ->
  #     {sub_width, sub_height} = Adam7.Pass.size(pass_index, width, height)
  #     split_pass = split_pixels_for_pass(
  #       {sub_width, sub_height},
  #       image,
  #       Enum.at(passes, pass_index - 1)
  #     )
  #     [split_pass | split_passes]
  #   end)
  #   |> Enum.reverse
  # end

  # defp split_pixels_for_pass(image_metadata, image, pass) do
  #   split_pixels_for_pass(image_metadata, image, pass, [])
  # end

  # # In the base case, we've split each of the rows and return them in the
  # # correct order
  # defp split_pixels_for_pass(_image_metadata, image, [], split_rows) do
  #   Enum.reverse split_rows
  # end

  # defp split_pixels_for_pass({row_width, _height}=image_metadata, image, [row | rows], split_rows) do
  #   split_row = split_pixels_for_row(row_width, image, row)
  #   split_pixels_for_pass(image_metadata, image, rows, [split_row | split_rows])
  # end

  # defp split_pixels_for_row(row_width, image, raw_row) do
  #   split_pixels_for_row(row_width, image, raw_row, [])
  # end

  # # In the base case, we've split out all of the necessary pixels
  # # There may be remaining bits in `_raw_row` when `color_formats * width` is
  # # not evenly divisible by 8.
  # defp split_pixels_for_row(0, image, _raw_row, split_pixels) do
  #   Enum.reverse split_pixels
  # end

  # defp split_pixels_for_row(width, image, raw_row, split_pixels) do
  #   <<pixel_chunk::bits-size(color_format), rest_raw_row::bits>> = raw_row
  #   split_pixels_for_row(width-1, color_format, rest_raw_row, [pixel_chunk | split_pixels])
  # end
end
