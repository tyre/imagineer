defmodule Imagineer.Image.PNG.Chunk.Encoders.Time do
  def encode(_image) do
    current_time = DateTime.utc_now()

    <<
      current_time.year::integer-size(16),
      current_time.month::integer-size(8),
      current_time.day::integer-size(8),
      current_time.hour::integer-size(8),
      current_time.minute::integer-size(8),
      current_time.second::integer-size(8)
    >>
  end
end
