defmodule Imagineer.YcrbrTest do
  use ExUnit.Case, async: true
  alias Imagineer.Ycrbr

  test "#red_value" do
    assert {96, 255, 48} == Ycrbr.red_value({255, 14, 14}, :jpeg)
  end
end
