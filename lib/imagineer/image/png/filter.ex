defmodule Imagineer.Image.PNG.Filter do
  alias Imagineer.Image.PNG

  @doc """
  Takes in a png and converts its `scanlines` into `unfiltered_rows`. Returns
  the png with the `unfiltered_rows` attribute set to a list of tuples of the
  for `{row_index, unfiltered_row_binary}`
  """
  def unfilter(%PNG{filter_method: filter_method, interlace_method: interlace_method}=image) do
    %PNG{image | unfiltered_rows: unfilter(filter_method, interlace_method, image)}
  end

  # With no interlacing, we can just go line by line
  defp unfilter(:five_basics, 0, %PNG{}=image) do
    PNG.Filter.Basic.unfilter(image.scanlines, image)
  end

  # With adam7 interlacing, we unfilter each pass' scanlines as a chunk
  defp unfilter(:five_basics, 1, %PNG{}=image) do
    Enum.reduce(image.scanlines, [], fn (pass, unfiltered_passes) ->
      unfiltered_pass = PNG.Filter.Basic.unfilter(pass, image)
      [unfiltered_pass | unfiltered_passes]
    end) |> Enum.reverse
  end

  def filter(%PNG{filter_method: filter_method, interlace_method: interlace_method}=image) do
    %PNG{image | scanlines: filter(filter_method, interlace_method, image)}
  end

  def filter(:five_basics, 0, %PNG{unfiltered_rows: unfiltered_rows}=image) do
    PNG.Filter.Basic.filter(unfiltered_rows, image)
  end

  def filter(:five_basics, 1, %PNG{unfiltered_rows: unfiltered_passes}=image) do
    Enum.reduce(unfiltered_passes, [], fn(pass, filtered_passes) ->
      filtered_pass = PNG.Filter.Basic.filter(pass, image)
      [filtered_pass | filtered_passes]
    end) |> Enum.reverse
  end
end
