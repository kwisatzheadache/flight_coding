defmodule Transmit do
  @moduledoc"""
  Module to handle sending messages within NN, using the genotype and corresponding PIDs.
  """

  @doc"""
  Send message to lists of neurons, sensors, or actuators, by PID.
  Messages to neurons are sent only to the first layer of neurons.
  """
  def list(component, genotype, message) do
    [neurons, sensors, actuators, _] = genotype
    first_layer_neurons = Enum.filter(neurons, fn x -> x.index == 1 end)
    case component do
      :sensors -> Enum.each(first_layer_neurons, fn x -> send x.pid, {message} end)
      :neurons -> Enum.each(sensors, fn x -> send x.pid, {message} end)
      :actuators -> Enum.each(actuators, fn x -> send x.pid, {message} end)
    end
  end

  @doc"""
  Transmit message to all pids
  """
  def all(genotype) do
    Enum.each(List.flatten(genotype), fn x -> send x.pid, {:terminate, "terminating"} end)
  end
end
