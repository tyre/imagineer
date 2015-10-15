Imagineer
=========

**N.B.**
Until 1.0 is reached, each beta release might include backwards incompatible changes.
1.0 will include parsing and writing of PNGs and JPEGs.

Image parsing in Elixir.

Currently Imagineer only supports PNGs. To load an image, create a new `Imagineer.Image` and pass it to the load function. Once the image is processed (or the raw binary is placed in the `raw` field by some other means), passing it to `process` will parse all of its data.

```elixir
alias Imagineer.Image
image = %Image{uri: "./test/support/images/alpaca.png"}
  |> Image.load
  |> Image.process
# =>
{:ok,
 %Imagineer.Image.PNG{alias: nil,
  attributes: %{"XML:com.adobe.xmp": "<x:xmpmeta xmlns:x=\"adobe:ns:meta/\" x:xmptk=\"XMP Core 5.4.0\">\n   <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">\n      <rdf:Description rdf:about=\"\"\n            xmlns:exif=\"http://ns.adobe.com/exif/1.0/\">\n         <exif:PixelXDimension>96</exif:PixelXDimension>\n         <exif:PixelYDimension>96</exif:PixelYDimension>\n      </rdf:Description>\n   </rdf:RDF>\n</x:xmpmeta>\n",
    pixel_dimensions: {5669, 5669, :meter}}, bit_depth: 8, color_format: :rgb8,
   color_type: 2, comment: nil, compression: :zlib,
   data_content: <<120, 1, 141, 189, 7, 148, 92, 213, 149, 254, 123, 99, 229, 208, 213, 57, 75, 106, 229, 0,
     66, 66, 18, 32, 178, 49, 57, 216, 132, 193, 9, 99, 96, 108, 6, 131, 3, 14, 51, 255, 97, ...>>,
   decompressed_data: nil, filter_method: :five_basics, format: :png, gamma: nil,
   height: 96, interface_method: 0, mask: nil, palette: [],
   pixels: [], # 96 rows of 96 3-element tuples each omitted for sanity.
   raw: <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 96, 0, 0, 0, 96, 8, 2, 0, 0, #0, 109, 250, ...>>,
   scanlines: [], unfiltered_rows: [], uri: nil, width: 96}}
```
