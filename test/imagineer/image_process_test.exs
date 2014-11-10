defmodule Imagineer.ImageProcessTest do
  use ExUnit.Case, async: true
  alias Imagineer.Image

  # Until ExUnit has contexts, we don't want to load all images on every `setup`
  test "it parses the alpaca" do
    image = %Image{uri: "./test/support/images/alpaca.png"} |>
            Image.load() |>
            Image.process()

    {:ok, raw_file} = File.read(image.uri)
    assert raw_file == image.raw, "it should set the file's contents into `raw`"

    assert image.format == :png, "it should set the image format"

    # It should set the width and height
    assert image.width == 96, "it should set the width"
    assert image.height == 96, "it should set the height"

    # It should set the color format, color type, and bit_depth
    assert image.bit_depth == 8, "it should set the bit depth"
    assert image.color_format == :rgb8, "it should set the color format"
    assert image.attributes.color_type == 2, "it should set the color type"

    assert image.attributes.pixel_dimensions == {5669, 5669, :meter},
           "it should set the pixel dimensions"

    xmp_text_chunk = "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"XMP Core 5.4.0\">\n   <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n      <rdf:Description rdf:about=\"\"\n            xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n         <exif:PixelXDimension>96</exif:PixelXDimension>\n         <exif:PixelYDimension>96</exif:PixelYDimension>\n      </rdf:Description>\n   </rdf:RDF>\n</x:xmpmeta>\n"
    assert image.attributes[:"XML:com.adobe.xmp"] == xmp_text_chunk,
           "it should pull arbitrary text chunks into attributes"
    # assert  == true
  end

  test "it parses the baby octopus" do
    image = %Image{uri: "./test/support/images/baby_octopus.png"} |>
            Image.load() |>
            Image.process()

    {:ok, raw_file} = File.read(image.uri)
    assert raw_file == image.raw, "it should set the file's contents into `raw`"
  end

  test "it can parse a jpg" do
    image = %Image{uri: "./test/support/images/drowning_girl.jpg"} |>
        Image.load() |>
        Image.process()
    assert image.format == :jpg
  end
end
