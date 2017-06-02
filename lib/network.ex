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
    sensors =   case is_atom(scape)
                  true -> Interactor.generate(scape, :sensor)
                  false -> IO.puts "Error: scape must be atom, :rng, :cube, or xor_sim for example"
                end
    actuators = case is_atom(scape)
                  true -> Interactor.generate(scape, :actuator)
                  false -> IO.puts "Error: scape must be atom, :rng, :cube, or xor_sim for example"
                end
    cortex = Cortex.generate(scape, type)
  end
end

