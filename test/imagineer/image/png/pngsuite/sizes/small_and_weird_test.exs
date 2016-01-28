defmodule Imagineer.Image.PNG.PngSuite.Sizes.SmallAndWeirdTest do
  use ExUnit.Case, async: true

  @test_path "test/support/images/pngsuite/sizes/"
  @tmp_path "./tmp/"

  test "1x1 palette interlaced (seriously who would do this?)" do
    {:ok, image} = Imagineer.load(@test_path <> "s01i3p01.png")

    assert image.height == 1
    assert image.width == 1
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s01i3p01_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s01i3p01_test.png")

    # assert image.height == 1
    # assert image.width == 1
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 1
    # assert image.interlace_method == 1
  end

  test "1x1 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s01n3p01.png")

    assert image.height == 1
    assert image.width == 1
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s01n3p01_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s01n3p01_test.png")

    assert image.height == 1
    assert image.width == 1
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0
  end

  test "2x2 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s02i3p01.png")

    assert image.height == 2
    assert image.width == 2
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s02i3p01_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s02i3p01_test.png")

    # assert image.height == 2
    # assert image.width == 2
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 1
    # assert image.interlace_method == 1
  end

  test "2x2 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s02n3p01.png")

    assert image.height == 2
    assert image.width == 2
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s02n3p01_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s02n3p01_test.png")

    assert image.height == 2
    assert image.width == 2
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0
  end

  test "3x3 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s03i3p01.png")

    assert image.height == 3
    assert image.width == 3
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s03i3p01_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s03i3p01_test.png")

    # assert image.height == 3
    # assert image.width == 3
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 1
    # assert image.interlace_method == 1
  end

  test "3x3 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s03n3p01.png")

    assert image.height == 3
    assert image.width == 3
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s03n3p01_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s03n3p01_test.png")

    assert image.height == 3
    assert image.width == 3
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0
  end

  test "4x4 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s04i3p01.png")

    assert image.height == 4
    assert image.width == 4
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s04i3p01_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s04i3p01_test.png")

    # assert image.height == 4
    # assert image.width == 4
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 1
    # assert image.interlace_method == 1
  end

  test "4x4 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s04n3p01.png")

    assert image.height == 4
    assert image.width == 4
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s04n3p01_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s04n3p01_test.png")

    assert image.height == 4
    assert image.width == 4
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 1
    assert image.interlace_method == 0
  end

  test "5x5 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s05i3p02.png")

    assert image.height == 5
    assert image.width == 5
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s05i3p02_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s05i3p02_test.png")

    # assert image.height == 5
    # assert image.width == 5
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 2
    # assert image.interlace_method == 1
  end

  test "5x5 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s05n3p02.png")

    assert image.height == 5
    assert image.width == 5
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s05n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s05n3p02_test.png")

    assert image.height == 5
    assert image.width == 5
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0
  end

  test "6x6 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s06i3p02.png")

    assert image.height == 6
    assert image.width == 6
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s06i3p02_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s06i3p02_test.png")

    # assert image.height == 6
    # assert image.width == 6
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 2
    # assert image.interlace_method == 1
  end

  test "6x6 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s06n3p02.png")

    assert image.height == 6
    assert image.width == 6
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s06n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s06n3p02_test.png")

    assert image.height == 6
    assert image.width == 6
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0
  end

  test "7x7 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s07i3p02.png")

    assert image.height == 7
    assert image.width == 7
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s07i3p02_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s07i3p02_test.png")

    # assert image.height == 7
    # assert image.width == 7
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 2
    # assert image.interlace_method == 1
  end

  test "7x7 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s07n3p02.png")

    assert image.height == 7
    assert image.width == 7
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s07n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s07n3p02_test.png")

    assert image.height == 7
    assert image.width == 7
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0
  end

  test "8x8 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s08i3p02.png")

    assert image.height == 8
    assert image.width == 8
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s08i3p02_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s08i3p02_test.png")

    # assert image.height == 8
    # assert image.width == 8
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 2
    # assert image.interlace_method == 1
  end

  test "8x8 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s08n3p02.png")

    assert image.height == 8
    assert image.width == 8
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s08n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s08n3p02_test.png")

    assert image.height == 8
    assert image.width == 8
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0
  end

  test "9x9 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s09i3p02.png")

    assert image.height == 9
    assert image.width == 9
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 1

    # :ok = Imagineer.write(image, @tmp_path <> "s09i3p02_test.png")
    # {:ok, image} = Imagineer.load(@tmp_path <> "s09i3p02_test.png")

    # assert image.height == 9
    # assert image.width == 9
    # assert image.color_format == :palette
    # assert image.color_type == 3
    # assert image.bit_depth == 2
    # assert image.interlace_method == 1
  end

  test "9x9 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s09n3p02.png")

    assert image.height == 9
    assert image.width == 9
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s09n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s09n3p02_test.png")

    assert image.height == 9
    assert image.width == 9
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 2
    assert image.interlace_method == 0
  end
end
