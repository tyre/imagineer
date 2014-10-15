defmodule Imagineer.ImageProcessTest do
  use ExUnit.Case, async: true
  alias Imagineer.Image
  alias Imagineer.Image.PNG

  setup do
    image = %Image{uri: "./test/support/images/alpaca.png"} |>
            Image.load() |>
            Image.process()

    {:ok, %{image: image}}
  end

  test "it stores the raw file in :raw", %{image: image} do
    {:ok, raw_file} = File.read(image.uri)
    assert raw_file == image.raw
  end

  test "it sets the format as a PNG", %{image: image} do
    assert image.format == :png
  end

  test "it reads in the width and height", %{image: image} do
    assert image.width == 96
    assert image.height == 96
  end

  test "it sets the color format, color type, and bit_depth", %{image: image} do
    assert image.bit_depth == 8
    assert image.color_format == :rgb8
    assert image.attributes.color_type == 2
  end

  test "it reads the pixel dimensions", %{image: image} do
    assert image.attributes.pixel_dimensions == {5669, 5669, :meter}
  end
end
