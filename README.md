Imagineer
=========

Image parsing in Elixir.

Currently Imagineer only supports PNGs. To load an image, create a new `Imagineer.Image` and pass it to the load function. Once the image is processed (or the raw binary is placed in the `raw` field by some other means), passing it to `process` will parse all of its data.

```elixir
alias Imagineer.Image
image = %Image{uri: "./test/support/images/alpaca.png"} |>
  Image.load() |>
  Image.process()
# =>
#  %Imagineer.Image{
#    alias: nil,
#    attributes: %{
#      color_type: 2,
#      compression: 0,
#      filter_method: 0,
#      interface_method: 0,
#      pixel_dimensions: {
#        5669,
#        5669,
#       :meter
#      }
#    },
#    bit_depth: 8,
#    color_format: :rgb8,
#    content: <<120, 1, 141, 189, 7, 148, 92, 213, 149, 254, 123, 99, 229, 208, 213, 57, 75, 106, 229, 0, 66, 66, 18, 32, 178, 49, 57, 216, 132, 193, 9, 99, 96, 108, 6, 131, 3, 14, 51, 255, 97, 198, 30, 71, 156, ...>>,
#    format: :png,
#    height: 96,
#    mask: nil,
#    raw: <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 96, 0, 0, 0, 96, 8, 2, 0, 0, 0, 109, 250, 224, 111, 0, 0, 12, 70, 105, 67, 67, 80, ...>>,
#    uri: "./test/support/images/alpaca.png",
#    width: 96}
```
