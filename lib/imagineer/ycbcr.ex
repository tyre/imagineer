defmodule Imagineer.Ycrbr do

  @jpeg_k 2
  @jpeg_kb 0.114
  @jpeg_kr 0.299

  @hd_k
  @hd_kb 0.0722
  @hd_kr 0.2126

  def to_rgb({_,_,_}=color, :jpeg) do
    to_rgb(color, @jpeg_k, @jpeg_kb, @jpeg_kr)
  end

  def to_rgb({_luma, _chromatic_blue, _chromatic_red}=color, k, kb, kr) do
    {
      red_value(color, k, kr),
      green_value(color, k, kb, kr),
      blue_value(color, k, kb)
    }
  end

  def red_value({_,_,_}=color, :jpeg) do
    red_value(color, @jpeg_k, @jpeg_kr)
  end

  def red_value({luma, _chromatic_blue, chromatic_red}, k, kr) do
    luma + k * (1 - kr) * chromatic_red
  end

  def blue_value({luma, chromatic_blue, _chromatic_red}, k, kb) do
    luma + k * (1 - kb) * chromatic_blue
  end

  def green_value({luma, chromatic_blue, chromatic_red}, k, kb, kr) do
    blue_color = k * (kb * (1 - kb) * chromatic_blue
    red_color = kr * (1 - kr) * chromatic_red) / (1 - kr - kb)
    luma - blue_color + red_color
  end

  def y_value(red, green, blue, kb, kr) do
    kr * red + (1 - kr - kb) * green + kb * blue
  end
end
