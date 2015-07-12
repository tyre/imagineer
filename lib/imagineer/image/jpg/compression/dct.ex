defmodule Imagineer.Image.JPG.Compression.DCT do
  alias Imagineer.Image.JPG

  @doc """
  Takes in a JPG and returns its `data_content` inflated with dct.

  ## Example

  Let's get real deep with some Tallest Man on Earth.

      iex> alias Imagineer.Image.JPG
      iex> JPG.Compression.DCT.decompress(%JPG{
      ...>  data_content: <<120, 156, 29, 140, 65, 14, 128, 32, 12, 4, 191, 178,
      ...>   55, 46, 198, 15, 112, 242, 200, 51, 208, 86, 37, 129, 150, 88, 136,
      ...>   241, 247, 162, 215, 217, 217, 89, 132, 208, 206, 100, 176, 72, 194,
      ...>   102, 19, 2, 172, 215, 170, 198, 30, 3, 31, 42, 18, 113, 106, 38,
      ...>   20, 70, 211, 33, 51, 142, 75, 187, 144, 199, 50, 206, 193, 21, 236,
      ...>   122, 109, 76, 223, 186, 167, 191, 199, 176, 150, 114, 246, 8, 130,
      ...>   136, 154, 227, 198, 120, 180, 227, 86, 113, 13, 43, 195, 253, 133,
      ...>   249, 5, 207, 168, 43, 42>>
      ...> })
      "And this sadness, I suppose; is gonna hold me to the ground; And I'm forced to find the still; In a place you won't be 'round."
  """
  def decompress(%JPG{data_content: compressed_data}) do
  end
end
