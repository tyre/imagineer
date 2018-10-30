defmodule Imagineer.Image.PNG.Chunk.Encoders.TimeTest do
  use ExUnit.Case, async: true
  alias Imagineer.Image.PNG
  alias Imagineer.Image.PNG.Chunk.Encoders.Time

  test "#encode returns the current time on write" do
    current_time = DateTime.utc_now()

    serialized_time = <<
      current_time.year::integer-size(16),
      current_time.month::integer-size(8),
      current_time.day::integer-size(8),
      current_time.hour::integer-size(8),
      current_time.minute::integer-size(8),
      current_time.second::integer-size(8)
    >>

    assert Time.encode(%PNG{}) == serialized_time
  end
end
