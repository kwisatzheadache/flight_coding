defmodule Network do
  @moduledoc"""
  Create a simple neural network to train across relatively simple tasks.
  """

  @doc"""
  The primary function of a neural net is to learn to produce the right output from
  a given input (learning). The train call receives the scape and size and creates
  accordingly.

  ex: Network.train(:rubix, :small)
  """
  def train(scape, size) do
    Network.create(:ffnn, scape, size)
  end

  def create(type, scape, size) do
    neurons = Neuron.create(size)
    sensors = Sensor.create(scape)
    actuators = Actuator.create(scape)
    cortex = Cortex.create(scape, type)
  end
end


defmodule Neuron do
  @moduledoc"""
  Neurons have the format {{:neuron, .37374628}, {weights}}
  """

  @doc"""
  Creates neurons corresponding to the size of nn desired. 
  """
  def create(size) do
    hld = HLD.generate(size)
  end
end

defmodule HLD do
  @moduledoc"""
  Hidden Layer Densities are the gooey insides of the neural net. Currently supported:
  ffnn, with hlds varying from 1 to 9 layers deep and as many neurons wide.
  """

  @doc"""
  Accepts three sizes of hld - :small, :medium, :large
  It creates a list of HLD with a depth and width randomly generated in the given size.
  """
  def generate(size) when is_atom(size) do
    true ->
      case size do
        :small -> HLD.generate(1, 3)
        :medium -> HLD.generate(3, 5)
        :large -> HLD.generate(6, 9)
      end
    _ -> IO.puts "HLD size must be one of the following atoms - :small, :medium, or :large"
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
