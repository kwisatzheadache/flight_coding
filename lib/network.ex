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

  @doc"""
  default creation - calls Network.create(:ffnn, :xor, :medium)
  """
  def create do
    create(:ffnn, :xor, :medium)
  end

  def create(type, scape, size) do
    if is_atom(scape) do
    [cortex] = Cortex.generate(scape, type)
    n= Neuron.generate(size)
    s= Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, n) end)
    a= Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, n) end)
    n_loaded = Neuron.assign_inputs_and_outputs(n, s, a)
    neurons = Enum.map(n_loaded, fn x -> %{x | cx_id: cortex.id} end)
    sensors = Enum.map(s, fn x -> %{x | cx_id: cortex.id} end)
    actuators = Enum.map(a, fn x -> %{x | cx_id: cortex.id} end)
    [neurons, sensors, actuators, [cortex]]
    else
      IO.puts "Error: scape must be an atom, ie :rng"
    end
  end
end

