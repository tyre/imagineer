defmodule Imagineer.Image.PNG.PngSuite.Ancillary.PhysicalPixelDimensionsTest do
  use ExUnit.Case, async: true

  @test_path "test/support/images/pngsuite/ancillary/"

  test "8 by 32 horizontal image" do
    {:ok, image} = Imagineer.load(@test_path <> "cdfn2c08.png")

    assert image.attributes.pixel_dimensions == {1, 4, :unknown}
  end

  test "32 by 8 vertical image" do
    {:ok, image} = Imagineer.load(@test_path <> "cdhn2c08.png")

    assert image.attributes.pixel_dimensions == {4, 1, :unknown}
  end

  test "another image" do
    {:ok, image} = Imagineer.load(@test_path <> "cdsn2c08.png")

    assert image.attributes.pixel_dimensions == {1, 1, :unknown}
  end

  test "with unit specifier" do
    {:ok, image} = Imagineer.load(@test_path <> "cdun2c08.png")

    assert image.attributes.pixel_dimensions == {1000, 1000, :meter}
  end
end
