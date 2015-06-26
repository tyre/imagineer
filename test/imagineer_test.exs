defmodule ImagineerTest do
  use ExUnit.Case

  test "loading a non-existent file" do
    uri = "./404.png"
    error_message = "Could not open #{uri} because the file does not exist."
    {:error, ^error_message} = Imagineer.load(uri)
  end

  test "loading a file of unknown type" do
    uri = "./test/support/images/jpg/black.jpg"
    error_message = "Unknown or unsupported image format."
    {:error, ^error_message} = Imagineer.load(uri)
  end
end
