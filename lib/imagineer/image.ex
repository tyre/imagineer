defmodule Imagineer.Image do
  use Behaviour
  @type supported_image :: %{}
  defcallback process(raw_content :: bitstring) :: supported_image
end
