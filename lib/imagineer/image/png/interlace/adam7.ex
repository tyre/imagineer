defmodule Imagineer.Image.PNG.Interlace.Adam7 do
  alias Imagineer.Image.PNG
  alias PNG.Interlace.Adam7

  @doc """
  Extract scanlines from the given image's decompressed data. The unfiltered
  rows will be grouped into 7 passes, each essentially a sub-image.
  """
  def extract_scanlines(image) do
    Adam7.Scanlines.extract(image)
  end

  def separate_passes(%PNG{pixels: pixels}) do
    Enum.map(1..7, fn(pass_number) ->
      Adam7.Pass.extract_pass(pass_number, pixels)
    end)
  end

  def merge_scanlines(%PNG{scanlines: scanlines}) do
    List.flatten(scanlines)
  end

  @doc """
  Merge the extracted seven passes into a corresponding image.
  """
  def merge(passes, {width, height}) do
    Enum.reduce(1..7, empty_image_rows(width, height), fn (pass, image_rows) ->
      Adam7.Pass.merge(pass, {width, height}, Enum.at(passes, pass-1), image_rows)
    end)
    |> :array.to_list
    |> Enum.map(&:array.to_list/1)
  end

  defp empty_image_rows(width, height) do
    :array.new([
      {:size, height},
      {:fixed, true},
      {:default, :array.new([
          {:size, width},
          {:fixed, true}
        ])
      }
    ])
  end
end
