defmodule Imagineer.Image.JPG.Compression do
  alias Imagineer.Image.JPG
  @moduledoc """
    Handles
  """

  @doc """
  Decompresses JPG data based on the passed in compression method.

  Currently only dct is supported.
  """
  def decompress(%JPG{compression: compression}=image) do
    decompressed_data = decompress(compression, image)
    Map.put(image, :decompressed_data, decompressed_data)
  end

  defp decompress(:dct, image) do
    JPG.Compression.DCT.decompress(image)
  end
end
