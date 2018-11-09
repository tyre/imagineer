defmodule Imagineer.Image.PNG.Chunk.Encoders.PhysicalPixelDimensionsTest do
  use ExUnit.Case, async: true
  alias Imagineer.Image.PNG
  alias Imagineer.Image.PNG.Chunk.Encoders.PhysicalPixelDimensions

  test "#encode with no dimensions" do
    assert PhysicalPixelDimensions.encode(%PNG{}) == nil
  end

  test "#encode with meter dimensions" do
    image = %PNG{attributes: %{pixel_dimensions: {110, 239, :meter}}}

    assert PhysicalPixelDimensions.encode(image) == <<
             110::integer-size(32),
             239::integer-size(32),
             1::size(1)
           >>
  end

  test "#encode with unknown dimensions" do
    image = %PNG{attributes: %{pixel_dimensions: {93278, 12874, :unknown}}}

    assert PhysicalPixelDimensions.encode(image) == <<
             93278::integer-size(32),
             12874::integer-size(32),
             0::size(1)
           >>
  end
end
