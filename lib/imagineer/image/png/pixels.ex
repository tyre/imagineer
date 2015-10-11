defmodule Imagineer.Image.PNG.Pixels do
  alias Imagineer.Image.PNG
  alias PNG.Pixels.NoInterlace
  alias PNG.Pixels.Adam7

  def extract(%PNG{interlace_method: 0}=image) do
    NoInterlace.extract(image)
  end

  def extract(%PNG{interlace_method: 1}=image) do
    Adam7.extract(image)
  end
end
