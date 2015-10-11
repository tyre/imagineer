defmodule Imagineer.Image.PNG.Pixels.Adam7 do
  alias Imagineer.Image.PNG
  alias PNG.Pixels.NoInterlace
  import PNG.Helpers, only: [bytes_per_row: 2, bytes_per_pixel: 1,
    channels_per_pixel: 1]
  use Bitwise

  @compile {:inline, chunk_number: 1 }

  def extract(%PNG{interlace_method: 1}=image) do
    interlace_pixels = interlace_passes_to_pixels(image)
    pixels = rebuild_pixels(interlace_pixels, image.width, image.height)
    %PNG{ image | pixels: pixels }
  end

  def rebuild_pixels(interlace_pixels, width, height) do
    rebuild_rows(width, height, height-1, interlace_pixels, [])
  end

  # In the base case, we've run through all of the rows and are left with a
  # reversed list of pixel rows
  def rebuild_rows(_width, height, -1, _interlace_pixels, rows) do
    rows
  end

  def rebuild_rows(width, height, row_index, interlace_pixels, rows) do
    current_pixel_row = pixel_row(width, height, row_index, interlace_pixels)
    rebuild_rows(width, height, row_index - 1, interlace_pixels, [current_pixel_row | rows])
  end

  # If the remainder of the row index divided by 2 is 0 then we know we're on a
  # line of sevens.
  # `7 7 7 7 7 7 7 7`
  defp pixel_row(width, height, row_index, interlace_pixels)
  when rem(row_index, 2) == 1 do
    pixel_row = elem(interlace_pixels, 6)
    pixel_row_index = div(row_index, 2)
    row = :array.get(pixel_row_index, pixel_row)
    |> Enum.slice(0, width)
    |> Enum.reverse
    row
  end

  # If the row index divided by 8 is 2 then we know we're on a line of
  # alternating 5s and 6s
  # `5 6 5 6 5 6 5 6`
  defp pixel_row(width, height, row_index, interlace_pixels)
  when rem(row_index, 8) == 2
  do
    fives = elem(interlace_pixels, 4)
    fives_index = chunk_number(row_index) * 2
    fives_pixels = Enum.slice(:array.get(fives_index, fives), 0, div(width, 2))
    |> Enum.reverse

    sixes = elem(interlace_pixels, 5)
    sixes_index = chunk_number(row_index) * 4
    sixes_pixels = :array.get(sixes_index, sixes)
    |> Enum.slice(0, div(width, 2))
    |> Enum.reverse

    zip_pixels(fives_pixels, sixes_pixels)
  end

  # If the row index divided by 8 is 6 then we know we're on a line of
  # alternating 5s and 6s
  # `5 6 5 6 5 6 5 6`
  defp pixel_row(width, height, row_index, interlace_pixels)
  when rem(row_index, 8) == 6
  do
    fives = elem(interlace_pixels, 4)
    fives_index = chunk_number(row_index) * 2 + 1
    fives_pixels = :array.get(fives_index, fives)
    |> Enum.slice(0, div(width, 2))
    |> Enum.reverse

    sixes = elem(interlace_pixels, 5)
    sixes_index = chunk_number(row_index) * 4 + 3
    sixes_pixels = :array.get(sixes_index, sixes)
    |> Enum.slice(0, div(width, 2))
    |> Enum.reverse

    zip_pixels(fives_pixels, sixes_pixels)
  end

  # 1 6 4 6 2 6 4 6
  # 7 7 7 7 7 7 7 7
  # 5 6 5 6 5 6 5 6
  # 7 7 7 7 7 7 7 7
  # 3 6 4 6 3 6 4 6
  # 7 7 7 7 7 7 7 7
  # 5 6 5 6 5 6 5 6
  # 7 7 7 7 7 7 7 7

  defp pixel_row(width, height, row_index, interlace_pixels)
  when rem(row_index, 8) == 0
  do
    ones = elem(interlace_pixels, 0)
    twos = elem(interlace_pixels, 1)
    fours = elem(interlace_pixels, 3)
    sixes = elem(interlace_pixels, 5)
    chunk_number = chunk_number(row_index)

    IO.puts("ones: #{inspect(Enum.slice(:array.get(chunk_number, ones), 3, 4))}")
    IO.puts("twos: #{inspect(Enum.slice(:array.get(chunk_number, twos), 3, 4))}")
    row = build_row_1(
      width,
      Enum.slice(:array.get(chunk_number, ones), 3, 4),
      Enum.slice(:array.get(chunk_number, twos), 3, 4),
      :array.get(chunk_number, fours),
      :array.get(chunk_number, sixes),
      []
    )
    row
  end

  # There has got to be a better way to do this. But I don't know it yet
  # I apologize profusely to everyone who taught me to code.
  #
  # I weep with you.
  defp build_row_1(0, _ones, _twos, _fours, _sixes, row) do
    row
  end

  defp build_row_1(1, [one|_ones], _twos, _fours, _sixes, row) do
    new_chunk = [one]
    row ++ new_chunk
  end

  defp build_row_1(2, [one|_ones], _twos, _fours, [s1|_sixes], row) do
    new_chunk = [one, s1]
    row ++ new_chunk
  end

  defp build_row_1(3, [one|_ones], _twos, [f1| _fours], [s1|_sixes], row) do
    new_chunk = [one, s1, f1]
    row ++ new_chunk
  end

  defp build_row_1(4, [one|_ones], _twos, [f1| _fours], [s1, s2|_sixes], row) do
    new_chunk = [one, s1, f1, s2]
    row ++ new_chunk
  end

  defp build_row_1(5, [one|_ones], [two|_twos], [f1 | _fours], [s1, s2|_sixes], row) do
    new_chunk = [one, s1, f1, s2, two]
    row ++ new_chunk
  end

  defp build_row_1(6, [one|_ones], [two|_twos], [f1 | _fours], [s1, s2, s3|_sixes], row) do
    new_chunk = [one, s1, f1, s2, two, s3]
    row ++ new_chunk
  end

  defp build_row_1(7, [one|ones], [two|_twos], [f1, f2 | _fours], [s1, s2, s3|_sixes], row) do
    new_chunk = [one, s1, f1, s2, two, s3, f2]
    row ++ new_chunk
  end

  # 1 6 4 6 2 6 4 6
  defp build_row_1(width, [one|ones], [two|twos], [f1, f2 | fours], [s1, s2, s3, s4|sixes], row) do
    new_chunk = [one, s1, f1, s2, two, s3, f2, s4]
    build_row_1(width - 8, ones, twos, fours, sixes, row ++ new_chunk)
  end

  defp pixel_row(width, height, row_index, interlace_pixels) do
    []
  end

  defp chunk_number(row_index) do
    div(row_index, 8)
  end

  defp zip_pixels(list_1, list_2) do
    zip_pixels(list_1, list_2, [])
  end

  defp zip_pixels([], _list_2, combined) do
    combined
  end

  defp zip_pixels(_list_1, [], combined) do
    combined
  end

  defp zip_pixels([h1 | list_1], [h2 | list_2], combined) do
    zip_pixels(list_1, list_2, [h1 | [h2 |combined]])
  end
  @doc """
  Generates a set of all coordinates (0-indexed) for a given width and height

  ## Examples
      iex> alias Imagineer.Image.PNG.Pixels.Adam7
      iex> Adam7.coordinates(5,4)
      [
        {0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0},
        {0, 1}, {1, 1}, {2, 1}, {3, 1}, {4, 1},
        {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2},
        {0, 3}, {1, 3}, {2, 3}, {3, 3}, {4, 3}
      ]
  """
  def coordinates(width, height) do
    coordinates(width-1, width-1, height-1, [])
  end

  # In the base case, we'll have reduced our way down to the origin and can stop
  defp coordinates(_width, 0, 0, points) do
    [{0,0} | points]
  end

  # If our current column is 0, add the first point for that row and recur for
  # the row before it.
  defp coordinates(width, 0, current_row, points) do
    coordinates(width, width, current_row - 1, [{0, current_row} | points])
  end

  defp coordinates(width, current_column, current_row, points) do
    new_points = [{current_column, current_row} | points]
    coordinates(width, current_column - 1, current_row, new_points)
  end


  # The scanlines are actually divided into seven lists. Each corresponds to a
  # given "pass" of the interlacing algorithm. We turn them into arrays because
  # we need to access them by index
  defp interlace_passes_to_pixels(image) do
    Enum.map(image.scanlines, fn (scanline) ->
      NoInterlace.extract_pixels(scanline, image)
      |> Enum.map(&Enum.reverse/1)
      |> :array.from_list
      |> :array.resize
    end)
    |> List.to_tuple
  end

  def extract_pixels(rows, %PNG{width: width, color_format: color_format, bit_depth: bit_depth}) do
    extract_pixels(rows, width, channels_per_pixel(color_format), bit_depth, [])
  end

  defp extract_pixels([], _width, _channels_per_pixel, _bit_depth, pixel_rows) do
    Enum.reverse(pixel_rows)
  end

  defp extract_pixels([row | unfiltered_rows], width, channels_per_pixel, bit_depth, pixel_rows) do
    pixel_row = extract_pixels_from_row(row, width, channels_per_pixel, bit_depth)
    extract_pixels(unfiltered_rows, width, channels_per_pixel, bit_depth, [pixel_row | pixel_rows])
  end

  defp extract_pixels_from_row(row, width, channels_per_pixel, bit_depth) do
    pixel_size = channels_per_pixel * bit_depth
    extract_pixels_from_row(row, width, channels_per_pixel, bit_depth, pixel_size, [])
  end

  # In the base case, we have pulled everything from the row and are left with
  # a reversed list of pixels. It is possible that `row` is larger than the number
  # of pixels because some pixels (e.g. 1 bit grayscale) do not always fill an
  # entire byte.
  defp extract_pixels_from_row(_row, 0, _channels_per_pixel, _bit_depth, _pixel_size, pixels) do
    Enum.reverse pixels
  end

  defp extract_pixels_from_row(row, width, channels_per_pixel, bit_depth, pixel_size, pixels) do
    <<pixel_bits::bits-size(pixel_size), rest_of_row::bits>> = row
    pixel = extract_pixel(pixel_bits, bit_depth, channels_per_pixel)
    extract_pixels_from_row(rest_of_row, width - 1, channels_per_pixel, bit_depth, pixel_size, [pixel | pixels])
  end

  defp extract_pixel(pixel_bits, bit_depth, channels_per_pixel) do
    extract_pixel(pixel_bits, bit_depth, [], channels_per_pixel)
  end

  # In the base case, we have no more channels to parse and we are done!
  defp extract_pixel(<<>>, _bit_depth, channel_list, 0) do
    List.to_tuple Enum.reverse channel_list
  end

  defp extract_pixel(pixel_bits, bit_depth, channel_list, channels) do
    remaining_channels = channels - 1
    rest_size = bit_depth * remaining_channels
    <<channel::integer-size(bit_depth), rest::bits-size(rest_size)>> = pixel_bits
    extract_pixel(rest, bit_depth, [channel | channel_list], remaining_channels)
  end
end
