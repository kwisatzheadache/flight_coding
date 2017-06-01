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
    neurons = Neuron.generate(size)
    sensors = Sensor.create(scape)
    actuators = Actuator.create(scape)
    cortex = Cortex.create(scape, type)
  end
end

defmodule Sensor do
  @moduledoc"""
  Sensors receive the input from the scape. As such, they ought to be tailored for each scape.
  We'll use a macro to call the module from the Sensor type.
  """

  defstruct id: nil, cx_id: nil, name: nil, scape: nil, vl: nil, fanout_ids: nil

  defmacro type(name) do
    quote do
      {{:., [], [{:__aliases__, [alias: false], [:Morphology]}, unquote(name)]}, [], [:sensor]}
    end
  end
  @doc"""
  """
  def generate(type) do
  end
end

defmodule Morphology do
  def RNG(interactor) do
    case interactor do
      :sensor ->
        [%Sensor{id: {:sensor, Generate.id()}, name: :xor_getinput, scape: {:private, xor_sim}, vl: 2}]
      :actuator ->
         [%Actuator{id: {:actuator, Generate.id()}, name: :xor_sendoutput, scape: {:private, xor_sim}, vl: 1}]
    end
  end
end

defmodule Neuron do
  @moduledoc"""
  Neurons have the format {{:neuron, .37374628}, {weights}}
  """

  @doc"""
  Creates neurons corresponding to the size of nn desired. 
  """
  def generate(size) do
    hld = case is_atom(size) do
          true -> 
            HLD.generate(size)
          _ -> IO.puts "HLD selected randomly"
                [bottom] = Enum.take_random(1..7, 1)
                HLD.generate(bottom, bottom + 2)
          end
    layers(hld, [], 0)
  end

  @doc"""
  Generate layers of neurons based on HLD. Assigns index corresponding to layer depth according to HLD.
  """
  def layers(hld, acc, index) do
    if length(hld) >= 1 do
      [layer | rem] = hld
      neurons = Neuron.create(layer, index + 1, [])
      layers(rem, [neurons | acc], index + 1)
    else
      List.flatten(acc)
    end
  end

  @doc"""
  Create neurons, assign weight and index, along with random ID.
  """
  def create(density, index, acc) do
    neuron = {{:neuron, Generate.id}, {:weights}, {:index, index}}
    case density do
      0 -> acc
      _ -> create(density - 1, index, [neuron | acc])
    end
  end
end

defmodule Generate do
  def id() do
    :random.uniform()
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
