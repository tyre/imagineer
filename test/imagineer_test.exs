defmodule ImagineerTest do
  use ExUnit.Case

  test "loading a non-existent file" do
    uri = "./404.png"
    {:error, "Could not open #{uri} due to :enoent"} == Imagineer.load(uri)
  end

  test "loading a file of unknown type" do
    uri = "./404.png"
    {:error, "Could not open #{uri} due to :enoent"} == Imagineer.load(uri)
  end
end
