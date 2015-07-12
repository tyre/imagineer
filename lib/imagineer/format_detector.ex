defmodule Imagineer.FormatDetector do
  @png_signature <<137::size(8), ?P, ?N, ?G,
                13::size(8), 10::size(8), 26::size(8), 10::size(8)>>
  @jpg_signature <<255::size(8), 216::size(8)>>

  def detect(<<@png_signature, _rest::binary>>), do: :png
  def detect(<<@jpg_signature, _rest::binary>>), do: :jpg
  def detect(_), do: :unknown
end
