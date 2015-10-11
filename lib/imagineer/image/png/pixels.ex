defmodule Imagineer.Image.PNG.Pixels do
  alias Imagineer.Image.PNG
  alias PNG.Pixels

  def extract(%PNG{interlace_method: 0}=image) do
    pixels = Pixels.NoInterlace.extract(image)
    Map.put(image, :pixels, pixels)
  end

  def extract(%PNG{interlace_method: 1}=image) do
    pixels = Pixels.Adam7.extract(image)
    Map.put(image, :pixels, pixels)
  end
end
