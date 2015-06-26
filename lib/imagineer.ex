defmodule Imagineer do
  alias Imagineer.FormatDetector
  alias Imagineer.Image.PNG

  def load(uri) do
    case File.read(uri) do
      {:ok, file} ->
        detect_type_and_process(file)
      {:error, reason} -> {:error, "Could not open #{uri} due to #{reason}" }
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
end
