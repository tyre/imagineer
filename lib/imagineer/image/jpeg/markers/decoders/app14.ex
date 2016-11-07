defmodule Imagineer.Image.JPEG.Markers.Decoders.APP14 do
  @transform_YCCK 2
  @transform_YCbCr 1
  @transform_unknown 0

  # Photoshop stores the type of color encoding here. We can skip this until we
  # know what to do with it
  def decode(<<"Adobe", _rest::binary>>, image) do
    image
  end
end
