defmodule Imagineer.Image.PNG.Interlace.Adam7.PassTest do
  alias Imagineer.Image.PNG.Interlace.Adam7
  use ExUnit.Case, async: true

  test "should get the pass sizes for a 8x8 image correctly" do
    assert Adam7.Pass.sizes(8, 8) == [
             {1, 1},
             {1, 1},
             {2, 1},
             {2, 2},
             {4, 2},
             {4, 4},
             {8, 4}
           ]
  end

  test "should get the pass sizes for a 12x12 image correctly" do
    assert Adam7.Pass.sizes(12, 12) == [
             {2, 2},
             {1, 2},
             {3, 1},
             {3, 3},
             {6, 3},
             {6, 6},
             {12, 6}
           ]
  end

  test "should get the pass sizes for a 33x47 image correctly" do
    assert Adam7.Pass.sizes(33, 47) == [
             {5, 6},
             {4, 6},
             {9, 6},
             {8, 12},
             {17, 12},
             {16, 24},
             {33, 23}
           ]
  end

  test "should get the pass sizes for a 1x1 image correctly" do
    assert Adam7.Pass.sizes(1, 1) == [
             {1, 1},
             {0, 1},
             {1, 0},
             {0, 1},
             {1, 0},
             {0, 1},
             {1, 0}
           ]
  end

  test "should get the pass sizes for a 0x0 image correctly" do
    assert Adam7.Pass.sizes(0, 0) == [
             {0, 0},
             {0, 0},
             {0, 0},
             {0, 0},
             {0, 0},
             {0, 0},
             {0, 0}
           ]
  end

  test "should always maintain the same amount of pixels in total" do
    Enum.each([{8, 8}, {12, 12}, {33, 47}, {1, 1}, {0, 0}], fn {width, height} ->
      pass_sizes = Adam7.Pass.sizes(width, height)
      reducer = fn {w, h}, sum -> sum + w * h end
      assert Enum.reduce(pass_sizes, 0, reducer) == width * height
    end)
  end
end
