# Imagineer

Image parsing in Elixir. No external dependencies.

## Status

Until 1.0 is reached, each beta release might include backwards incompatible changes.
1.0 will include parsing and writing of PNGs and JPEGs.

Currently Imagineer only supports reading and writing a subset of PNGs.

**If you run into an image that Imagineer cannot handle, please open an issue
and include the image.** There are a ridiculous number of possiblities, not all
of which are yet supported. With your help, we can get there.

## Loading an image

To load an image, call `Imagineer.load(path_to_file)`.

```elixir
alias Imagineer.Image
Imagineer.load("./test/support/images/alpaca.png")
# =>
{:ok,
 %Imagineer.Image.PNG{alias: nil,
  attributes: %{"XML:com.adobe.xmp": "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"XMP Core 5.4.0\">\n   <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n      <rdf:Description rdf:about=\"\"\n            xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n         <exif:PixelXDimension>96</exif:PixelXDimension>\n         <exif:PixelYDimension>96</exif:PixelYDimension>\n      </rdf:Description>\n   </rdf:RDF>\n</x:xmpmeta>\n",
    pixel_dimensions: {5669, 5669, :meter}}, bit_depth: 8, color_format: :rgb,
   color_type: 2, comment: nil, compression: :zlib,
   data_content: <<120, 1, 141, 189, 7, 148, 92, 213, 149, 254, 123, 99, 229, 208, 213, 57, 75, 106, 229, 0,
     66, 66, 18, 32, 178, 49, 57, 216, 132, 193, 9, 99, 96, 108, 6, 131, 3, 14, 51, 255, 97, ...>>,
   decompressed_data: nil, filter_method: :five_basics, format: :png, gamma: nil,
   height: 96, interface_method: 0, mask: nil, palette: [],
   pixels: [{238, 233, 224}, {241, 236, 227}, {238, 234, 225}, {238, 233, 225},
    {234, 228, 218}, {228, 222, 210}, {237, 231, 218}, {239, 234, 220}, ...], # 96 rows of 96 3-element tuples each omitted for sanity.
   raw: <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 96, 0, 0, 0, 96, 8, 2, 0, 0, #0, 109, 250, ...>>,
   scanlines: [], unfiltered_rows: [], uri: nil, width: 96}}
```

## Writing an image

To write an image to disk, simply pass an image and a location to
`Imagineer.write`.

```elixir
{:ok, png} = Imagineer.load("./test/support/images/alpaca.png")
:ok = Imagineer.write(png, "./tmp/alpaca-copy.png")
```

Image modules also respond to `to_binary`, which will give you the equivalent
of the file contents:

```elixir
{:ok, png} = Imagineer.load("./test/support/images/alpaca.png")
Imagineer.Image.PNG.to_binary(png)
```

## Image structure

You probably only care about the following fields:

* `width`
* `height`
* `pixels`
* `color_format`
* `format`
* `palette`
* `gamma`
* `bit_depth`

The `color_format` tells you how pixels are structured. `:rgb` indicates
that each pixel will be a three value tuple (red, blue, and green channels.)

The `bit_depth` signifies the size of each channel. For example, a `bit_depth` of `8` says that each channel is 8 bits, translating to values between 0-255.
