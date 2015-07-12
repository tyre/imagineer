defmodule Imagineer.Image.PNG.Filter do
  alias Imagineer.Image.PNG

  @doc """
  Takes in a png and converts its `scanlines` into `unfiltered_rows`. Returns
  the png with the `unfiltered_rows` attribute set to a list of tuples of the
  for `{row_index, unfiltered_row_binary}`
  """
  def unfilter(%PNG{filter_method: filter_method}=image) do
    unfiltered_rows = unfilter(filter_method, image)
    Map.put(image, :unfiltered_rows, unfiltered_rows)
  end

  defp unfilter(:five_basics, %PNG{}=image) do
    PNG.Filter.Basic.unfilter(image)
  end
end
