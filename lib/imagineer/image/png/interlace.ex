defmodule Imagineer.Image.PNG.Interlace do
  alias Imagineer.Image.PNG

  @moduledoc """
  A module for extracting and storing scanlines from images based on their
  interlace method.
  """

  @doc """
  Extracts scanlines for an image based on its interlace method.
  """
  def extract_pixels(%PNG{interlace_method: 0}=image) do
    %PNG{image | scanlines: PNG.Interlace.None.extract_scanlines(image)}
  end

  def extract_pixels(%PNG{interlace_method: 1}=image) do
    %PNG{image | scanlines: PNG.Interlace.Adam7.extract_scanlines(image)}
  end

  def encode_scanlines(%PNG{interlace_method: 0}=image) do
    %PNG{image | decompressed_data: PNG.Interlace.None.encode_scanlines(image)}
  end

  def encode_scanlines(%PNG{interlace_method: 1}) do
    raise "Encoding for Adam7 scanlines not yet supported"
  end
end
