defmodule Imagineer do
  alias Imagineer.FormatDetector
  alias Imagineer.Image.PNG

  @doc """
  Loads the file from the given location and processes it into the correct
  file type.
  Returns `{:ok, image}` if successful or `{:error, error_message}` otherwise
  """
  @spec load(uri :: binary) :: {:ok, %{}} | {:error, binary}
  def load(uri) do
    case File.read(uri) do
      {:ok, file} ->
        detect_type_and_process(file)
      {:error, reason} -> {:error, "Could not open #{uri} #{file_error_description(reason)}" }
    end
  end

  defp detect_type_and_process(content) do
    case FormatDetector.detect(content) do
      :png ->
        {:ok, PNG.process(content)}
      :unknown ->
        {:error, "Unknown or unsupported image format."}
    end
  end

  defp file_error_description(:enoent), do: "because the file does not exist."
  defp file_error_description(reason), do: "due to #{reason}."
end
