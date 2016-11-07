defmodule Imagineer.Image.JPEG.PixelsText do
  use ExUnit.Case, async: true

  test "it can parse a jpg" do
    image = %Imagineer.Image{uri: "./test/support/images/jpg/huff_simple0.jpg"} |>
        Imagineer.Image.load() |>
        Imagineer.Image.process()
    assert image.format == :jpg
  end
end
