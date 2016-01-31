defmodule Imagineer.Image.PNG.PngSuite.TransparencyTest do
  use ExUnit.Case, async: true

  @test_path "test/support/images/pngsuite/transparency/"
  @tmp_path "./tmp/"

  test "greyscale, transparent black background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbbn0g04.png")

    assert image.background == {0}
    assert image.transparency == {0}

    :ok = Imagineer.write(image, @tmp_path <> "tbbn0g04_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbbn0g04_test.png")

    assert image.background == {0}
    assert image.transparency == {0}
  end

  test "rgb, transparent blue background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbbn2c16.png")

    assert image.background == {0, 0, 65535}
    assert image.transparency == {65535, 65535, 65535}

    :ok = Imagineer.write(image, @tmp_path <> "tbbn2c16_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbbn2c16_test.png")

    assert image.background == {0, 0, 65535}
    assert image.transparency == {65535, 65535, 65535}
  end

  test "rgb palette, transparent black background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbbn3p08.png")

    assert image.background == {0, 0, 0}
    assert image.transparency == :array.from_list([0], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tbbn3p08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbbn3p08_test.png")

    assert image.background == {0, 0, 0}
    assert image.transparency == :array.from_list([0], 255)
  end

  test "rgb, transparent green background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbgn2c16.png")

    assert image.background == {0, 65535, 0}
    assert image.transparency == {65535, 65535, 65535}

    :ok = Imagineer.write(image, @tmp_path <> "tbgn2c16_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbgn2c16_test.png")

    assert image.background == {0, 65535, 0}
    assert image.transparency == {65535, 65535, 65535}
  end

  test "rgb palette, transparent, light-gray background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbgn3p08.png")

    assert image.background == {170, 170, 170}
    assert image.transparency == :array.from_list([0], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tbgn3p08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbgn3p08_test.png")

    assert image.background == {170, 170, 170}
    assert image.transparency == :array.from_list([0], 255)
  end

  test "RGB, transparent, red background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbrn2c08.png")

    assert image.background == {255, 0, 0}
    assert image.transparency == {0, 0, 0}

    :ok = Imagineer.write(image, @tmp_path <> "tbrn2c08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbrn2c08_test.png")

    assert image.background == {255, 0, 0}
    assert image.transparency == {0, 0, 0}
  end

  test "grayscale, transparent, white background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbwn0g16.png")

    assert image.background == {65535}
    assert image.transparency == {65535}

    :ok = Imagineer.write(image, @tmp_path <> "tbwn0g16_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbwn0g16_test.png")

    assert image.background == {65535}
    assert image.transparency == {65535}
  end

  test "rgb palette, transparent, white background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbwn3p08.png")

    assert image.background == {255, 255, 255}
    assert image.transparency == :array.from_list([0], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tbwn3p08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbwn3p08_test.png")

    assert image.background == {255, 255, 255}
    assert image.transparency == :array.from_list([0], 255)
  end

  test "rgb palette, transparent, yellow background" do
    {:ok, image} = Imagineer.load(@test_path <> "tbyn3p08.png")

    assert image.background == {255, 255, 0}
    assert image.transparency == :array.from_list([0], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tbyn3p08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tbyn3p08_test.png")

    assert image.background == {255, 255, 0}
    assert image.transparency == :array.from_list([0], 255)
  end

  test "rgb palette, transparent, but no background chunk" do
    {:ok, image} = Imagineer.load(@test_path <> "tp1n3p08.png")

    assert image.background == nil
    assert image.transparency == :array.from_list([0], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tp1n3p08_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tp1n3p08_test.png")

    assert image.background == nil
    assert image.transparency == :array.from_list([0], 255)
  end

  test "rgb palette, multiple levels of transparency, 3 entries" do
    {:ok, image} = Imagineer.load(@test_path <> "tm3n3p02.png")

    assert image.background == nil
    assert image.transparency == :array.from_list([0, 85, 170], 255)

    :ok = Imagineer.write(image, @tmp_path <> "tm3n3p02_test.png")
    {:ok, image} = Imagineer.load(@tmp_path <> "tm3n3p02_test.png")

    assert image.background == nil
    assert image.transparency == :array.from_list([0, 85, 170], 255)
  end
end
