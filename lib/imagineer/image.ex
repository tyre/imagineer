defmodule Imagineer.Image do
  defstruct alias: nil, width: nil, height: nil, mask: nil, bit_depth: nil,
            color_format: nil, uri: nil, format: nil, attributes: %{}, content: <<>>,
            raw: nil, comment: nil
  alias Imagineer.Image
  alias Imagineer.Image.PNG
  alias Imagineer.Image.JPG

  @png_signature <<137::size(8), 80::size(8), 78::size(8), 71::size(8),
                13::size(8), 10::size(8), 26::size(8), 10::size(8)>>
  @jpg_signature <<255::size(8), 216::size(8)>>

  def load(%Image{uri: uri}=image) do
    case File.read(uri) do
      {:ok, file} ->
        %Image{image | raw: file}
      {:error, reason} -> {:error, "Could not open #{uri} due to #{reason}" }
    end
  end

  def process(%Image{format: :png}=image) do
    PNG.process(image)
  end

  def process(%Image{format: :jpg}=image) do
    JPG.process(image)
  end

  def process(%Image{raw: raw}=image) when not is_nil(raw) do
    process %Image{ image | format: detect_format(image.raw) }
  end

  defp detect_format(<<@png_signature, _png_body::binary>>) do
    :png
  end

  defp detect_format(<<@jpg_signature, _png_body::binary>>) do
    :jpg
  end
end
