defmodule Imagineer.Image.PNG.Interlace.Adam7Test do
  use ExUnit.Case, async: true
  alias Imagineer.Image.PNG
  alias PNG.Interlace.Adam7
  doctest Imagineer.Image.PNG.Interlace.Adam7

  test "pixel_counts_per_pass" do
    assert Adam7.pixel_counts_per_pass(%PNG{height: 32, width: 32}) ==
           [16, 16, 32, 64, 128, 256, 512]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 32, width: 31}) ==
           [16, 16, 32, 64, 128, 240, 496]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 31, width: 31}) ==
           [16, 16, 32, 64, 128, 240, 465]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 31, width: 30}) ==
           [16, 16, 32, 56, 120, 240, 450]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 31, width: 29}) ==
           [16, 16, 32, 56, 120, 224, 435]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 31, width: 28}) ==
           [16, 12, 28, 56, 112, 224, 420]
    assert Adam7.pixel_counts_per_pass(%PNG{height: 30, width: 28}) ==
           [16, 12, 28, 56, 98, 210, 420]
  end


# 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6 1 6 4 6 2 6 4 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6 3 6 4 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
# 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6 5 6
# 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7
end
