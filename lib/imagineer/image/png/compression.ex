defmodule Imagineer.Image.PNG.Compression do
  alias Imagineer.Image.PNG
  @moduledoc """
    Handles
  """

  @doc """
  Decompresses PNG data based on the passed in compression method.

  Currently only zlib is supported.
  """
  def decompress(%PNG{compression: compression}=image) do
    decompressed_data = decompress(compression, image)
    Map.put(image, :decompressed_data, decompressed_data)
  end

  defp decompress(:zlib, image) do
    PNG.Compression.Zlib.decompress(image)
  end
end
