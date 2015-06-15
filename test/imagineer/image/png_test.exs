defmodule Imagineer.Image.PNGTest do
  use ExUnit.Case, async: true

  # Until ExUnit has contexts, we don't want to load all images on every `setup`
  test "it parses the alpaca" do
    {:ok, image} = Imagineer.load("./test/support/images/png/alpaca.png")

  #   assert image.format == :png, "it should set the image format"

  #   # It should set the width and height
  #   assert image.width == 96, "it should set the width"
  #   assert image.height == 96, "it should set the height"

    # It should set the color format, color type, and 1it_depth
    assert image.bit_depth == 8, "it should set the bit depth"
    assert image.color_format == :rgb, "it should set the color format"
    assert image.color_type == 2, "it should set the color type"

  #   assert image.attributes.pixel_dimensions == {5669, 5669, :meter},
  #          "it should set the pixel dimensions"

    # it should parse out rows of pixels equal to the height
    assert length(image.pixels) == image.height

    # each row of pixel should be equal to the width in length
    Enum.each(image.pixels, fn (pixel_row) -> assert length(pixel_row) == image.width end)

    xmp_text_chunk = "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"XMP Core 5.4.0\">\n   <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n      <rdf:Description rdf:about=\"\"\n            xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n         <exif:PixelXDimension>96</exif:PixelXDimension>\n         <exif:PixelYDimension>96</exif:PixelYDimension>\n      </rdf:Description>\n   </rdf:RDF>\n</x:xmpmeta>\n"
    assert image.attributes[:"XML:com.adobe.xmp"] == xmp_text_chunk,
           "it should pull arbitrary text chunks into attributes"
  end

  test "it can parse a jpg" do
    image = %Imagineer.Image{uri: "./test/support/images/jpg/drowning_girl.jpg"} |>
        Imagineer.Image.load() |>
        Imagineer.Image.process()
    assert image.format == :jpg
  end
end
