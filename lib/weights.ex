defmodule Weights do
  @moduledoc"""
  Used to generate, fetch, update, and perturb weights in Neurons
  """

  @doc"""
  Generates weights based on vl
  """
  def generate(vl, acc) do
    if vl == 0 do
      acc
    else
      weight = :random.uniform()
      generate(vl - 1, [weight | acc])
    end
  end

  def assign(neuron) do
    vl = length(neuron.input_neurons) + 1
    %{neuron | weights: generate(vl, [])}
  end
end
