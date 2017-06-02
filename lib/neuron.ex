
defmodule Neuron do
  @moduledoc"""
  Neurons have the format {{:neuron, .37374628}, {weights}}
  """

  defstruct id: nil, pid: nil, af: :tanh, input_neurons: [], output_neurons: [], index: nil, weights: nil

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
  Default create() creates a single neuron, calling create(1, 1, [])
  """
  def create do
    create(1, 1, [])
  end

  def create(density, index, acc) do
    neuron = [%Neuron{id: {:neuron, Generate.id}, weights: {:weights}, index: index}]
    case density do
      0 -> acc
      _ -> create(density - 1, index, [neuron | acc])
    end
  end
end

