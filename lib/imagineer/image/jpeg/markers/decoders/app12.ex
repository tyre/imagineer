defmodule Imagineer.Image.JPEG.Markers.Decoders.APP12 do
  @ducky_signature <<68, 117, 99, 107, 121, 0>>

  @quality_tag_id 1
  @comment_tag_id 2
  @copyright_tag_id 3

  # Adobe uses this to print out some info
  def decode(<<@ducky_signature,
               tag_id::integer-size(8),
               tag_length::integer-size(16),
               rest::binary>>,
    image)
  do
    <<tag_content::bytes-size(tag_length), _rest::binary>> = rest
    decode_tag_information(tag_id, tag_content, image)
  end

  # If not the Ducky signature, then we don't care. #PullRequestsAccepted
  def decode(<<_rest::binary>>, image) do
    image
  end

  # Stores the quality as a percent. So 80 is equal to 80% export quality
  # (the default in Photoshop when saving for web)
  defp decode_tag_information(@quality_tag_id,
                              <<quality::integer-size(32), _rest>>,
                              image)
  do
    %{ image | quality: quality }
  end

  # We don't care about this. #PullRequestsAccepted
  defp decode_tag_information(@comment_tag_id,
                              _whatever,
                              image)
  do
    image
  end

  # We don't care about this. #PullRequestsAccepted
  defp decode_tag_information(@copyright_tag_id,
                              _whatever,
                              image)
  do
    image
  end

  #
  defp decode_tag_information(_unknown_tag_id,
                              _whatever,
                              image)
  do
    image
  end
end
