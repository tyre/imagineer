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
    assert image.header.width == 96
    assert image.header.height == 96
  end

  test "it sets the color type", %{image: image} do
    assert image.header.color_type == :rgb
  end


# IO.puts inspect image.header.data_precision
# IO.puts inspect image.header.compression
# IO.puts inspect image.header.filter_method
# IO.puts inspect image.header.interface_method
end
