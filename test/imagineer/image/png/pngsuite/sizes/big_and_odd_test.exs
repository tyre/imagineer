defmodule Imagineer.Image.PNG.PngSuite.Sizes.BigAndOddTest do
  use ExUnit.Case, async: true

  @test_path "test/support/images/pngsuite/sizes/"
  @tmp_path "./tmp/"

  test "32x32 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s32i3p04.png")

    assert image.height == 32
    assert image.width == 32
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s32i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s32i3p04_test.png")

    assert image.height == 32
    assert image.width == 32
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "32x32 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s32n3p04.png")

    assert image.height == 32
    assert image.width == 32
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s32n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s32n3p04_test.png")

    assert image.height == 32
    assert image.width == 32
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "33x33 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s33i3p04.png")

    assert image.height == 33
    assert image.width == 33
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s33i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s33i3p04_test.png")

    assert image.height == 33
    assert image.width == 33
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "33x33 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s33n3p04.png")

    assert image.height == 33
    assert image.width == 33
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s33n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s33n3p04_test.png")

    assert image.height == 33
    assert image.width == 33
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "34x34 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s34i3p04.png")

    assert image.height == 34
    assert image.width == 34
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s34i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s34i3p04_test.png")

    assert image.height == 34
    assert image.width == 34
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "34x34 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s34n3p04.png")

    assert image.height == 34
    assert image.width == 34
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s34n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s34n3p04_test.png")

    assert image.height == 34
    assert image.width == 34
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "35x35 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s35i3p04.png")

    assert image.height == 35
    assert image.width == 35
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s35i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s35i3p04_test.png")

    assert image.height == 35
    assert image.width == 35
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "35x35 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s35n3p04.png")

    assert image.height == 35
    assert image.width == 35
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s35n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s35n3p04_test.png")

    assert image.height == 35
    assert image.width == 35
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "36x36 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s36i3p04.png")

    assert image.height == 36
    assert image.width == 36
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s36i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s36i3p04_test.png")

    assert image.height == 36
    assert image.width == 36
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "36x36 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s36n3p04.png")

    assert image.height == 36
    assert image.width == 36
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s36n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s36n3p04_test.png")

    assert image.height == 36
    assert image.width == 36
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "37x37 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s37i3p04.png")

    assert image.height == 37
    assert image.width == 37
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s37i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s37i3p04_test.png")

    assert image.height == 37
    assert image.width == 37
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "37x37 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s37n3p04.png")

    assert image.height == 37
    assert image.width == 37
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s37n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s37n3p04_test.png")

    assert image.height == 37
    assert image.width == 37
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "38x38 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s38i3p04.png")

    assert image.height == 38
    assert image.width == 38
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s38i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s38i3p04_test.png")

    assert image.height == 38
    assert image.width == 38
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "38x38 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s38n3p04.png")

    assert image.height == 38
    assert image.width == 38
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s38n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s38n3p04_test.png")

    assert image.height == 38
    assert image.width == 38
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "39x39 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s39i3p04.png")

    assert image.height == 39
    assert image.width == 39
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s39i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s39i3p04_test.png")

    assert image.height == 39
    assert image.width == 39
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "39x39 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s39n3p04.png")

    assert image.height == 39
    assert image.width == 39
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s39n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s39n3p04_test.png")

    assert image.height == 39
    assert image.width == 39
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end

  test "40x40 palette interlaced" do
    {:ok, image} = Imagineer.load(@test_path <> "s40i3p04.png")

    assert image.height == 40
    assert image.width == 40
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1

    :ok = Imagineer.write(image, @tmp_path <> "s40i3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s40i3p04_test.png")

    assert image.height == 40
    assert image.width == 40
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 1
  end

  test "40x40 palette" do
    {:ok, image} = Imagineer.load(@test_path <> "s40n3p04.png")

    assert image.height == 40
    assert image.width == 40
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0

    :ok = Imagineer.write(image, @tmp_path <> "s40n3p04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "s40n3p04_test.png")

    assert image.height == 40
    assert image.width == 40
    assert image.color_format == :palette
    assert image.color_type == 3
    assert image.bit_depth == 4
    assert image.interlace_method == 0
  end
end
