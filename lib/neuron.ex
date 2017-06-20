
defmodule Neuron do
  @moduledoc"""
  Neurons have the format {{:neuron, .37374628}, {weights}}
  """

  defstruct cortex_id: nil, cortex_pid: nil, id: nil, pid: nil, af: :tanh, input_neurons: [], output_neurons: [], output_pids: nil, index: nil, weights: nil

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

  @doc"""
  Receives the list of neurons and interactors. Reads the index values and assigns
  input and output neurons, such that each neuron feeds forward.
  """
  def assign_inputs_outputs_and_weights(neurons, sensors, actuators) do
    Enum.map(neurons, fn x ->  %{x | input_neurons: input_neurons(neurons, sensors, x.index),
                                     output_neurons: output_neurons(neurons, actuators, x.index)
                                } end)
    |> Enum.map(fn x -> %{x | weights: Weights.generate(length(x.input_neurons) + 1, [])} end)
  end

  @doc"""
  Grabs the neurons with corresponding index value, creates list with their ids. For the first layer,
  it grabs the sensors.

  Neuron.input_neurons(neurons, sensors, index)
  """
  def input_neurons(neurons, sensors, index) do
    case index == 1 do
          true ->  Enum.map(sensors, fn x -> x.id end)
          false -> neurons
                   |> Enum.filter(fn x -> x.index == index - 1 end)
                   |> Enum.map(fn x -> x.id end)
    end
  end

  @doc"""
  Same as input_neurons(), creates a list of output ids. For the final layer, actuators are used.
  """
  def output_neurons(neurons, actuators, index) do
    max = Enum.max(Enum.map(neurons, fn x -> x.index end))
    case index == max do
      true  -> Enum.map(actuators, fn x -> x.id end)
      false -> neurons
            |> Enum.filter(fn x -> x.index == index + 1 end)
            |> Enum.map(fn x -> x.id end)
    end
  end

  def run(neuron, acc) do
    receive do
      {:update_pids, output_pids, cortex_pid} -> %{neuron | output_pids: output_pids, cortex_pid: cortex_pid}
        |> run(acc)
      {:fire, input_vector} -> Transmit.neurons(neuron.output_pids, {:input_vector, neuron.id, af(input_vector, neuron.weights)})
        run(neuron, acc)
      {:input_vector, incoming_neuron, input} -> input_list = [{incoming_neuron, input} | acc]
        case length(input_list) == length(neuron.input_neurons) do
            true -> input_vector = Enum.map(neuron.input_neurons, fn x -> Enum.find(input_list, fn {incoming_neuron, input} -> x == incoming_neuron end) end)
              |> Enum.map(fn {incoming_neuron, input} -> input end)
              input_vector_with_bias = List.flatten([input_vector, 1])
              Transmit.neurons(neuron.output_pids, {:input_vector, neuron.id, af(input_vector_with_bias, neuron.weights)})
            false -> run(neuron, input_list)
        end
      {:test, _} -> Transmit.neurons(neuron.output_pids, {:test, :neuron})
        run(neuron, acc)
      {:terminate} -> IO.puts "exiting neuron"
        Process.exit(self(), :normal)
    end
  end

  def af(input_vector, weights) do
    dot = dot(input_vector, weights, [], 0)
    :math.tanh(dot)
  end

  def dot(a, b) do
    dot(a, b, [], 0)
  end

  def dot(matrix1, matrix2, acc, counter) do
    if counter < length(matrix1) do
      sum = Enum.at(matrix1, counter) * Enum.at(matrix2, counter)
      dot(matrix1, matrix2, [sum | acc], counter + 1)
    else
      Enum.sum(acc)
    end
  end
end

