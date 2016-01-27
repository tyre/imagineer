defmodule Imagineer.Image.PNG.Filter.BasicTest do
  use ExUnit.Case, async: true
  alias Imagineer.Image.PNG
  alias PNG.Filter.Basic, as: BasicFilter

  test "unfiltering with no filter" do
    scanlines = [<<0, 127, 138, 255, 20, 21, 107>>, <<0, 1, 77, 16, 234, 234, 154>>]
    unfiltered_lines = BasicFilter.unfilter(scanlines, %PNG{color_format: :rgb, bit_depth: 8, width: 6})
    assert unfiltered_lines ==
           [<<127, 138, 255, 20, 21, 107>>, <<1, 77, 16, 234, 234, 154>>]

  end

  test "unfiltering with all kinds of filters!" do
    scanlines = [
      <<1, 127, 138, 255, 20, 21, 107>>, # Sub filter
      <<0, 233, 1, 77, 78, 191, 144>>,   # None filter
      <<2, 1, 77, 16, 234, 234, 154>>,   # Up filter
      <<3, 67, 123, 98, 142, 117, 3>>,   # Average filter
      <<4, 104, 44, 87, 33, 91, 188>>    # Paeth filter
    ]
    unfiltered_lines = BasicFilter.unfilter(scanlines, %PNG{color_format: :rgb, bit_depth: 8, width: 6})
    assert unfiltered_lines ==
           [
            <<127, 138, 255, 147, 159, 106>>,
            <<233, 1, 77, 78, 191, 144>>,
            <<234, 78, 93, 56, 169, 42>>,
            <<184, 162, 144, 6, 26, 96>>,
            <<32, 206, 231, 39, 117, 76>>
          ]
  end
end
