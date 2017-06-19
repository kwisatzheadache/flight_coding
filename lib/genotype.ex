defmodule Genotype do
  @moduledoc """
  Generates, saves, recalls, modifies genotypes
  """

  @doc"""
  default genotype generator - calls Genotype.create(:ffnn, :xor, :medium)
  """
  def create do
    create(:ffnn, :xor, :medium)
  end

  @doc"""
  Creates a genotype with neurons, sensors, actuators - each according to the given type (FFNN) and scape.
  """
  def create(type, scape, size) do
    [c] = Cortex.generate(scape, type)
    neurons = Neuron.generate(size) #Empty neurons
    sensors = Interactor.generate(scape, :sensor)
      |> Enum.map(fn x -> Interactor.fanout_neurons(x, neurons) end)
    actuators = Interactor.generate(scape, :actuator)
      |> Enum.map(fn x -> Interactor.fanin_neurons(x, neurons) end)
    neurons_plus = Neuron.assign_inputs_outputs_and_weights(neurons, sensors, actuators) # Neurons assigned input_neurons, output_neurons, and weights
                  |> Enum.map(fn x -> %{x | cortex_id: c.id} end) # Neurons given cx_id
    sensors_plus = Enum.map(sensors, fn x -> %{x | cortex_id: c.id} end) # Sensors given cx_id
    actuators_plus = Enum.map(actuators, fn x -> %{x | cortex_id: c.id, output_pids: c.id} end) # Actuators given cx_id
    genotype = [neurons_plus, sensors_plus, actuators_plus, [c]]  
    genotype
  end

  @doc"""
  Updates weights and connections within a genotype. Called by the Train.genotype module
  """
  def update(genotype) do
    [neurons | rest] = genotype
    neurons_updated = Enum.map(neurons, fn x -> Weights.update(x) end)
    [neurons_updated | rest]
  end
end
