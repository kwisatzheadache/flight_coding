defmodule HLD do
  @moduledoc"""
  Hidden Layer Densities are the gooey insides of the neural net. Currently supported:
  ffnn, with hlds varying from 1 to 9 layers deep and as many neurons wide.
  """

  @doc"""
  Accepts three sizes of hld - :small, :medium, :large
  It creates a list of HLD with a depth and width randomly generated in the given size.
  """
  def generate(size) do
    case size do
      :small -> HLD.generate(1, 3)
      :medium -> HLD.generate(3, 5)
      :large -> HLD.generate(7, 9)
      :massive -> HLD.generate(30, 32)
    end
  end

  @doc"""
  If a more particular dimensionality is preferred, specify the bottom and top.
  """
  def generate(bottom, top) do
    [layers] = Enum.take_random(bottom..top, 1)
    densities = iterate(top, layers, [])
  end

  def iterate(size, layers, acc) do
    if layers == 0 do
      acc
    else
    [layer] = Enum.take_random((size - 2)..size, 1)
    iterate(size, layers - 1, [layer | acc])
    end
  end
end
