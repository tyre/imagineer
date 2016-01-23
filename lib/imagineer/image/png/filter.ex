defmodule Imagineer.Image.PNG.Filter do
  alias Imagineer.Image.PNG

  @doc """
  Takes in a png and converts its `scanlines` into `unfiltered_rows`. Returns
  the png with the `unfiltered_rows` attribute set to a list of tuples of the
  for `{row_index, unfiltered_row_binary}`
  """
  def unfilter(%PNG{filter_method: filter_method, interlace_method: interlace_method}=image) do
    unfiltered_rows = unfilter(filter_method, interlace_method, image)
    Map.put(image, :unfiltered_rows, unfiltered_rows)
  end

  # With no interlacing, we can just go line by line
  defp unfilter(:five_basics, 0, %PNG{}=image) do
    PNG.Filter.Basic.unfilter(image.scanlines, image.color_format, image.width)
  end

  # With adam7 interlacing, we unfilter each pass' scanlines as a chunk
  defp unfilter(:five_basics, 1, %PNG{}=image) do
    Enum.reduce(image.scanlines, [], fn (pass, unfiltered_passes) ->
      unfiltered_pass = PNG.Filter.Basic.unfilter(pass, image.color_format, image.width)
      [unfiltered_pass | unfiltered_passes]
    end) |> Enum.reverse
  end

  def filter(%PNG{filter_method: :five_basics, interlace_method: 0}=image) do
    %PNG{image | scanlines: PNG.Filter.Basic.filter(image)}
  end
end
