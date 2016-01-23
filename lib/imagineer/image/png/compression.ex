defmodule Imagineer.Image.PNG.Compression do
  alias Imagineer.Image.PNG
  alias PNG.Compression.Zlib
  @moduledoc """
    Handles
  """

  @doc """
  Decompresses PNG data based on the passed in compression method.

  Currently only zlib is supported.
  """
  def decompress(%PNG{compression: :zlib}=image) do
    %PNG{image | decompressed_data: Zlib.decompress(image) }
  end

  @doc """
  Compress PNG data based on compression method.

  Currently only zlib is supported.
  """
  def compress(%PNG{compression: :zlib}=image) do
    %PNG{image | data_content: Zlib.compress(image) }
  end
end
