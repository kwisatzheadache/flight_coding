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
    neurons = Neuron.generate(size)
    IO.inspect neurons
    sensors =   case is_atom(scape) do
                  true -> Interactor.generate(scape, :sensor)
                  false -> IO.puts "Error: scape must be atom, :rng, :cube, or xor_sim for example"
                end
    IO.inspect sensors
    actuators = case is_atom(scape) do
                  true -> Interactor.generate(scape, :actuator)
                  false -> IO.puts "Error: scape must be atom, :rng, :cube, or xor_sim for example"
                end
    IO.inspect actuators
    cortex = Cortex.generate(scape, type)
    IO.inspect cortex
  end
end

defmodule Cortex do
  @moduledoc"""
  """

  defstruct id: nil, pid: nil, scape: nil, type: :ffnn

  @doc"""
  """
  def generate(scape, type) do
    case is_atom(scape) and is_atom(type) do
      true -> [%Cortex{id: {:cortex, Generate.id}, scape: scape, type: type}]
      false -> IO.puts "scape and type must both be atoms"
    end
  end
end
