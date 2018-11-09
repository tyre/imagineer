defmodule Imagineer.Image.PNG.Chunk.Decoders.Time do
  alias Imagineer.Image.PNG

  def decode(
        <<year::integer-size(16), month::integer-size(8), day::integer-size(8),
          hour::integer-size(8), minute::integer-size(8), second::integer-size(8)>> = _content,
        %PNG{} = image
      ) do
    %PNG{
      image
      | last_modified: %DateTime{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          std_offset: 0,
          time_zone: "Etc/UTC",
          utc_offset: 0,
          zone_abbr: "UTC"
        }
    }
  end
end
