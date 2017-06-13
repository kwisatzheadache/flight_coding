defmodule Genotype do
  @moduledoc """
  Generates, saves, recalls, modifies genotypes
  """

  def generic do
    create(:ffnn, :xor, :medium)
  end

  def create(type, scape, size) do
    [c] = Cortex.generate(scape, type)
    n = Neuron.generate(size)
    s= Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, n) end)
    a= Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, n) end)
    n1 = Neuron.assign_inputs_outputs_and_weights(n, s, a) # Neurons assigned input_neurons, output_neurons, and weights
    n2 = Enum.map(n1, fn x -> %{x | cx_id: c.id} end) # Neurons given cx_id
    s2 = Enum.map(s, fn x -> %{x | cx_id: c.id} end) # Sensors given cx_id
    a2 = Enum.map(a, fn x -> %{x | cx_id: c.id} end) # Actuators given cx_id
    genotype = [n2, s2, a2, [c]]  
    genotype
  end
end
