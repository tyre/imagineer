defmodule Imagineer.ImageProcessTest do
  use ExUnit.Case, async: true

  # Until ExUnit has contexts, we don't want to load all images on every `setup`
  test "it parses the alpaca" do
    {:ok, image} = Imagineer.load("./test/support/images/png/alpaca.png")

    {:ok, raw_file} = File.read("./test/support/images/png/alpaca.png")
    assert raw_file == image.raw, "it should set the file's contents into `raw`"

    assert image.format == :png, "it should set the image format"

    # It should set the width and height
    assert image.width == 96, "it should set the width"
    assert image.height == 96, "it should set the height"

    # It should set the color format, color type, and bit_depth
    assert image.bit_depth == 8, "it should set the bit depth"
    assert image.color_format == :rgb8, "it should set the color format"
    assert image.color_type == 2, "it should set the color type"

    assert image.attributes.pixel_dimensions == {5669, 5669, :meter},
           "it should set the pixel dimensions"

    # it should parse out rows of pixels equal to the height
    assert length(image.pixels) == image.height

    # each row of pixel should be equal to the width in length
    Enum.each(image.pixels, fn (pixel_row) -> assert length(pixel_row) == image.width end)

    xmp_text_chunk = "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"XMP Core 5.4.0\">\n   <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n      <rdf:Description rdf:about=\"\"\n            xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n         <exif:PixelXDimension>96</exif:PixelXDimension>\n         <exif:PixelYDimension>96</exif:PixelYDimension>\n      </rdf:Description>\n   </rdf:RDF>\n</x:xmpmeta>\n"
    assert image.attributes[:"XML:com.adobe.xmp"] == xmp_text_chunk,
           "it should pull arbitrary text chunks into attributes"
  end

  test "it parses the baby octopus" do
    {:ok, image} = Imagineer.load("./test/support/images/png/baby_octopus.png")

    {:ok, raw_file} = File.read("./test/support/images/png/baby_octopus.png")
    assert raw_file == image.raw, "it should set the file's contents into `raw`"
  end

# Image: test/support/images/jpg/black.jpg
#   Format: JPEG (Joint Photographic Experts Group JFIF format)
#   Mime type: image/jpeg
#   Class: DirectClass
#   Geometry: 200x144+0+0
#   Units: Undefined
#   Type: Grayscale
#   Base type: Grayscale
#   Endianess: Undefined
#   Colorspace: Gray
#   Depth: 8-bit
#   Channel depth:
#     gray: 8-bit
#   Channel statistics:
#     Pixels: 28800
#     Gray:
#       min: 2 (0.00784314)
#       max: 2 (0.00784314)
#       mean: 2 (0.00784314)
#       standard deviation: 0 (0)
#       kurtosis: 0
#       skewness: 0
#   Colors: 1
#   Histogram:
#      28800: (  2,  2,  2) #020202 gray(2)
#   Rendering intent: Perceptual
#   Gamma: 0.454545
#   Chromaticity:
#     red primary: (0.64,0.33)
#     green primary: (0.3,0.6)
#     blue primary: (0.15,0.06)
#     white point: (0.3127,0.329)
#   Background color: gray(255)
#   Border color: gray(223)
#   Matte color: gray(189)
#   Transparent color: gray(0)
#   Interlace: None
#   Intensity: Undefined
#   Compose: Over
#   Page geometry: 200x144+0+0
#   Dispose: Undefined
#   Iterations: 0
#   Compression: JPEG
#   Quality: 50
#   Orientation: Undefined
#   Properties:
#     comment: VTC-2.3 YUV
#     date:create: 2015-06-10T19:42:22-07:00
#     date:modify: 2015-06-10T19:42:22-07:00
#     jpeg:colorspace: 2
#     jpeg:sampling-factor: 2x1,1x1,1x1
#     signature: 3ae28ca36ded757756bbc483c35afe741edcf15b9abaaa5695c6a80640a08702
#   Artifacts:
#     filename: test/support/images/jpg/black.jpg
#     verbose: true
#   Tainted: True
#   Filesize: 1.24KB
#   Number pixels: 28.8K
#   Pixels per second: 2.88MB
#   User time: 0.000u
#   Elapsed time: 0:01.009
#   Version: ImageMagick 6.8.9-8 Q16 x86_64 2014-12-22 http://www.imagemagick.org

  test "it can parse a jpg" do
    {:ok, image} = Imagineer.load("./test/support/images/jpg/black.jpg")
    assert image.format == :jpg
  end
end
